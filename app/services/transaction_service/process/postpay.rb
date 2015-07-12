module TransactionService::Process

  # Partly implemented postpay process. Much of the postpay
  # implementation still resides in controllers and there's no active
  # plan to port it over because it's very likely to be removed
  # altogether soon.
  class Postpay

    TxStore = TransactionService::Store::Transaction

    def create(tx:, gateway_fields:, gateway_adapter:, prefer_async:)
      Transition.transition_to(tx[:id], :pending)

      Result::Success.new({result: true})
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

    def send_message(tx, message, sender_id)
      TxStore.add_message(community_id: tx[:community_id],
                          transaction_id: tx[:id],
                          message: message,
                          sender_id: sender_id)
    end
  end
end
