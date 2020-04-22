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

      res =
        if tx.current_state == :preauthorized
          Result::Success.new()
        else
          new_state = tx.stripe_payments.last.try(:intent_requires_action?) ? :payment_intent_requires_action : :preauthorized
          transition_tx = TransactionService::StateMachine.transition_to(tx.id, new_state)
          if transition_tx && transition_tx.current_state.to_sym == new_state
            Result::Success.new()
          elsif transition_tx&.booking&.errors&.any?
            Result::Error.new(
              TransactionService::Transaction::BookingDatesInvalid.new(
                I18n.t("error_messages.booking.double_booking_payment_voided")))
          else
            Result::Error.new('Generic payment error')
          end
        end

      res.and_then {
        Result::Success.new(TransactionService::Transaction.create_transaction_response(tx))
      }
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
