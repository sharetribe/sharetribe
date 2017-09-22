# coding: utf-8
module TransactionService::Process
  Gateway = TransactionService::Gateway
  Worker = TransactionService::Worker
  ProcessStatus = TransactionService::DataTypes::ProcessStatus
  DataTypes = TransactionService::DataTypes::Transaction

  class Preauthorize

    TxStore = TransactionService::Store::Transaction

    def create(tx:, gateway_fields:, gateway_adapter:, force_sync:)
      Transition.transition_to(tx[:id], :initiated)
      tx[:current_state] = :initiated

      if !force_sync
        proc_token = Worker.enqueue_preauthorize_op(
          community_id: tx[:community_id],
          transaction_id: tx[:id],
          op_name: :do_create,
          op_input: [tx, gateway_fields])

        proc_status_response(proc_token)
      else
        do_create(tx, gateway_fields)
      end
    end

    def do_create(tx, gateway_fields)
      gateway_adapter = TransactionService::Transaction.gateway_adapter(tx[:payment_gateway])

      completion = gateway_adapter.create_payment(
        tx: tx,
        gateway_fields: gateway_fields,
        force_sync: true)

      Gateway.unwrap_completion(completion) do
        finalize_create(tx: tx, gateway_adapter: gateway_adapter, force_sync: true)
      end
    end

    def finalize_create(tx:, gateway_adapter:, force_sync:)
      ensure_can_execute!(tx: tx, allowed_states: [:initiated, :preauthorized])

      if !force_sync
        proc_token = Worker.enqueue_preauthorize_op(
          community_id: tx[:community_id],
          transaction_id: tx[:id],
          op_name: :do_finalize_create,
          op_input: [tx[:id], tx[:community_id]])

        proc_status_response(proc_token)
      else
        do_finalize_create(tx[:id], tx[:community_id])
      end
    end

    def do_finalize_create(transaction_id, community_id)
      tx = TxStore.get_in_community(community_id: community_id, transaction_id: transaction_id)
      gateway_adapter = TransactionService::Transaction.gateway_adapter(tx[:payment_gateway])

      res =
        if tx[:current_state] == :preauthorized
          Result::Success.new()
        else
          booking_res =
            if tx[:availability] != :booking
              Result::Success.new()
            else

              initiate_booking(tx: tx).on_error { |error_msg, data|
                logger.error("Failed to initiate booking #{data.inspect} #{error_msg}", :failed_initiate_booking, tx.slice(:community_id, :id).merge(error_msg: error_msg))

                void_res = gateway_adapter.reject_payment(tx: tx, reason: "")[:response]

                void_res.on_success {
                  logger.info("Payment voided after failed transaction", :void_payment, tx.slice(:community_id, :id))
                }.on_error { |payment_error_msg, payment_data|
                  logger.error("Failed to void payment after failed booking", :failed_void_payment, tx.slice(:community_id, :id).merge(error_msg: payment_error_msg))
                }
              }.on_success { |data|
                response_body = data[:body]
                booking = response_body[:data]

                TxStore.update_booking_uuid(
                  community_id: tx[:community_id],
                  transaction_id: tx[:id],
                  booking_uuid: booking[:id]
                )
              }
            end

          booking_res.on_success {
            Transition.transition_to(tx[:id], :preauthorized)
          }
        end

      res.and_then {
        Result::Success.new(DataTypes.create_transaction_response(tx))
      }
    end

    def reject(tx:, message:, sender_id:, gateway_adapter:)
      res = Gateway.unwrap_completion(
        gateway_adapter.reject_payment(tx: tx, reason: "")) do

        Transition.transition_to(tx[:id], :rejected)
      end

      if res[:success] && message.present?
        send_message(tx, message, sender_id)
      end

      res
    end

    def complete_preauthorization(tx:, message:, sender_id:, gateway_adapter:)
      res = Gateway.unwrap_completion(
        gateway_adapter.complete_preauthorization(tx: tx)) do

        Transition.transition_to(tx[:id], :paid)
      end

      if res[:success] && message.present?
        send_message(tx, message, sender_id)
      end

      res
    end

    def complete(tx:, message:, sender_id:, gateway_adapter:)
      Transition.transition_to(tx[:id], :confirmed)
      TxStore.mark_as_unseen_by_other(community_id: tx[:community_id],
                                      transaction_id: tx[:id],
                                      person_id: tx[:listing_author_id])

      if message.present?
        send_message(tx, message, sender_id)
      end

      Result::Success.new({result: true})
    end

    def cancel(tx:, message:, sender_id:, gateway_adapter:)
      Transition.transition_to(tx[:id], :canceled)
      TxStore.mark_as_unseen_by_other(community_id: tx[:community_id],
                                      transaction_id: tx[:id],
                                      person_id: tx[:listing_author_id])

      if message.present?
        send_message(tx, message, sender_id)
      end

      Result::Success.new({result: true})
    end


    private

    def initiate_booking(tx:)
      auth_context = {
        marketplace_id: tx[:community_uuid],
        actor_id: tx[:starter_uuid]
      }

      HarmonyClient.post(
        :initiate_booking,
        body: {
          marketplaceId: tx[:community_uuid],
          refId: tx[:listing_uuid],
          customerId: tx[:starter_uuid],
          initialStatus: :paid,
          start: tx[:booking][:start_on],
          end: tx[:booking][:end_on]
        },
        opts: {
          max_attempts: 3,
          auth_context: auth_context
        }).rescue { |error_msg, data|

        new_data =
          if data[:error].present?
            # An error occurred, assume connection issue
            {reason: :connection_issue, listing_id: tx[:listing_id]}
          else
            case data[:status]
            when 409
              # Conflict or double bookings, assume double booking
              {reason: :double_booking, listing_id: tx[:listing_id]}
            else
              # Unknown. Return unchanged.
              data
            end
          end

        Result::Error.new(error_msg, new_data.merge(listing_id: tx[:listing_id]))
      }
    end

    def send_message(tx, message, sender_id)
      TxStore.add_message(community_id: tx[:community_id],
                          transaction_id: tx[:id],
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
      tx_state = tx[:current_state]

      unless allowed_states.include?(tx_state)
        raise TransactionService::Transaction::IllegalTransactionStateException.new(
               "Transaction was in illegal state, expected state: [#{allowed_states.join(',')}], actual state: #{tx_state}")
      end
    end
  end
end
