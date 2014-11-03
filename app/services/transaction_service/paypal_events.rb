module TransactionService::PaypalEvents

  module_function

  # Paypal payment request was cancelled, remove the associated transaction
  def request_cancelled(source, token)
    delete_transaction(cid: token[:community_id], tx_id: token[:transaction_id])
  end

  def payment_updated(source, payment)
    tx = MarketplaceService::Transaction::Query.transaction(payment[:transaction_id])
    if (tx)
      case transition_type(tx, payment)
      when :initiated_to_preauthorized
        initiated_to_preauthorized(tx)
      when :initiated_to_voided
        delete_transaction(cid: tx[:community_id], tx_id: tx[:id])
      else
        # No handler yet, should log but how to get a logger?
      end
    end
  end


  ## Privates

  # TODO source not yet passed here, add when needed
  def transition_type(tx, payment)
    payment_status = payment[:payment_status]
    pending_reason = payment[:pending_reason]
    tx_state = tx[:status]

    case [tx_state, payment_status, pending_reason]
    when ["initiated", :pending, :authorization]
      :initiated_to_preauthorized
    when ["initiated", :voided, :none]
      :initiated_to_voided
    when ["preauthorized", :voided, :none]
    else
      :unknown_transition
    end
  end


  def initiated_to_preauthorized(tx)
    MarketplaceService::Transaction::Command.transition_to(tx[:id], "preauthorized")
  end

  def delete_transaction(cid:, tx_id:)
    tx = Transaction.where(community_id: cid, id: tx_id).first
    tx.conversation.destroy if Maybe(tx).conversation.map { |c| c.messages.empty? }.or_else(false)
    tx.destroy if tx
  end

end
