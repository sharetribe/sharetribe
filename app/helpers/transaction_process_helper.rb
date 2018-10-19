module TransactionProcessHelper
  TxStore = TransactionService::Store::Transaction

  def complete(tx:, message:, sender_id:, gateway_adapter:)
    TransactionService::StateMachine.transition_to(tx.id, :confirmed)
    TxStore.mark_as_unseen_by_other(community_id: tx.community_id,
                                    transaction_id: tx.id,
                                    person_id: tx.listing_author_id)

    if message.present?
      send_message(tx, message, sender_id)
    end

    Result::Success.new({result: true})
  end

  private

  def send_message(tx, message, sender_id)
    TxStore.add_message(community_id: tx.community_id,
                        transaction_id: tx.id,
                        message: message,
                        sender_id: sender_id)
  end
end