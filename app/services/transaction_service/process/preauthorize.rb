module TransactionService::Process
  Gateway = TransactionService::Gateway
  Worker = TransactionService::Worker
  ProcessStatus = TransactionService::DataTypes::ProcessStatus

  class Preauthorize

    TxStore = TransactionService::Store::Transaction

    def create(tx:, gateway_fields:, gateway_adapter:, force_sync:)
      TransactionService::StateMachine.transition_to(tx.id, :initiated)
      tx.current_state = :initiated

      if !force_sync
        proc_token = Worker.enqueue_preauthorize_op(
          community_id: tx.community_id,
          transaction_id: tx.id,
          op_name: :do_create,
          op_input: [tx, gateway_fields])

        proc_status_response(proc_token)
      else
        do_create(tx, gateway_fields)
      end
    end

    def do_create(tx, gateway_fields)
      gateway_adapter = TransactionService::Transaction.gateway_adapter(tx.payment_gateway)

      completion = gateway_adapter.create_payment(
        tx: tx,
        gateway_fields: gateway_fields,
        force_sync: true)

      if completion[:success]
        if completion[:sync]
          finalize_res = finalize_create(tx: tx, gateway_adapter: gateway_adapter, force_sync: true)
          if finalize_res.success
            completion[:response]
          else
            delete_failed_transaction(tx)
            finalize_res
          end
        else
          completion[:response]
        end
      elsif !completion[:success]
        delete_failed_transaction(tx)
        completion[:response]
      end
    end

    def finalize_create(tx:, gateway_adapter:, force_sync:)
      ensure_can_execute!(tx: tx, allowed_states: [:initiated, :preauthorized])

      if !force_sync
        proc_token = Worker.enqueue_preauthorize_op(
          community_id: tx.community_id,
          transaction_id: tx.id,
          op_name: :do_finalize_create,
          op_input: [tx.id, tx.community_id])

        proc_status_response(proc_token)
      else
        do_finalize_create(tx.id, tx.community_id)
      end
    end

    def do_finalize_create(transaction_id, community_id)
      tx = TxStore.get_in_community(community_id: community_id, transaction_id: transaction_id)
      gateway_adapter = TransactionService::Transaction.gateway_adapter(tx.payment_gateway)

      res =
        if tx.current_state == :preauthorized
          Result::Success.new()
        else
          # The booking validation is done here, but at this point, the
          # transaction is still in :initiated state. This means that two
          # requests with overlapping bookings can both pass this validation,
          # because the other transaction is still :initiated.
          booking_res =
            if tx.availability.to_sym == :booking && !tx.booking.valid?
              void_payment(gateway_adapter, tx)
              Result::Error.new(TransactionService::Transaction::BookingDatesInvalid.new(I18n.t("error_messages.booking.double_booking_payment_voided")))
            else
              Result::Success.new()
            end

          booking_res.on_success {
            # The transaction goes to the next state that actually blocks
            # availability only here. So this transition and the validation
            # above must happen in a single database transaction, using listing
            # locking, as you did in
            # TransactionService::Store::Transaction.create

            # I propose two ways to solve this:

            # - Option 1: We move the validation for tx.booking.valid? to happen
            # within the transition_to calls below, so that the state machine
            # can handle the db transaction and lock the listing, etc.

            # Option 2: wrap the entire body of do_finalize_create in a
            # transaction and lock the listing on top. I'm not sure how that
            # would play along with the state machine's after_transition actions
            # that have after_commit: true


            # After this is done, the locking/transaction from TxStore.create
            # can be removed, as it does not have much effect for preventing
            # overlapping bookings.
            if tx.stripe_payments.last.try(:intent_requires_action?)
              TransactionService::StateMachine.transition_to(tx.id, :payment_intent_requires_action)
            else
              TransactionService::StateMachine.transition_to(tx.id, :preauthorized)
            end
          }
        end

      res.and_then {
        Result::Success.new(TransactionService::Transaction.create_transaction_response(tx))
      }
    end

    def void_payment(gateway_adapter, tx)
      void_res = gateway_adapter.reject_payment(tx: tx, reason: "")[:response]

      void_res.on_success {
        logger.info("Payment voided after failed transaction", :void_payment, tx.slice(:community_id, :id))
      }.on_error { |payment_error_msg, payment_data|
        logger.error("Failed to void payment after failed booking", :failed_void_payment, tx.slice(:community_id, :id).merge(error_msg: payment_error_msg))
      }
      void_res
    end

    def reject(tx:, message:, sender_id:, gateway_adapter:)
      res = Gateway.unwrap_completion(
        gateway_adapter.reject_payment(tx: tx, reason: "")) do

        TransactionService::StateMachine.transition_to(tx.id, :rejected)
      end

      if res[:success] && message.present?
        send_message(tx, message, sender_id)
      end

      res
    end

    def complete_preauthorization(tx:, message:, sender_id:, gateway_adapter:)
      res = Gateway.unwrap_completion(
        gateway_adapter.complete_preauthorization(tx: tx)) do

        TransactionService::StateMachine.transition_to(tx.id, :paid)
      end

      if res[:success] && message.present?
        send_message(tx, message, sender_id)
      end

      res
    end

    def complete(tx:, message:, sender_id:, gateway_adapter:, metadata: {})
      TransactionService::StateMachine.transition_to(tx.id, :confirmed, metadata)
      TxStore.mark_as_unseen_by_other(community_id: tx.community_id,
                                      transaction_id: tx.id,
                                      person_id: tx.listing_author_id)

      if message.present?
        send_message(tx, message, sender_id)
      end

      Result::Success.new({result: true})
    end

    def cancel(tx:, message:, sender_id:, gateway_adapter:, metadata: {})
      TransactionService::StateMachine.transition_to(tx.id, :disputed, metadata)
      TxStore.mark_as_unseen_by_other(community_id: tx.community_id,
                                      transaction_id: tx.id,
                                      person_id: tx.listing_author_id)

      if message.present?
        send_message(tx, message, sender_id)
      end

      Result::Success.new({result: true})
    end

    # Stripe gateway works in sync mode. Failed transaction will be deleted.
    def delete_failed_transaction(tx)
      if tx.payment_gateway == :stripe
        TransactionService::Store::Transaction.delete(community_id: tx.community_id, transaction_id: tx.id)
      end
    end

    private

    def send_message(tx, message, sender_id)
      TxStore.add_message(community_id: tx.community_id,
                          transaction_id: tx.id,
                          message: message,
                          sender_id: sender_id)
    end

    def proc_status_response(proc_token)
      Result::Success.new(
        ProcessStatus.create_process_status({
                                              process_token: proc_token[:process_token],
                                              completed: proc_token[:op_completed],
                                              result: proc_token[:op_output]}))
    end

    def logger
      @logger ||= SharetribeLogger.new(:preauthorize_process)
    end

    def ensure_can_execute!(tx:, allowed_states:)
      tx_state = tx.current_state

      unless allowed_states.include?(tx_state.to_sym)
        raise TransactionService::Transaction::IllegalTransactionStateException.new(
               "Transaction was in illegal state, expected state: [#{allowed_states.join(',')}], actual state: #{tx_state}")
      end
    end
  end
end
