module TransactionService::PaypalEvents

  module_function

  # Paypal payment request was cancelled, remove the associated transaction
  def request_cancelled(token)
    Transaction.where(community_id: token[:community_id], id: token[:transaction_id]).destroy_all
  end

  def payment_updated(payment)
    tx = MarketplaceService::Transaction::Query.transaction(payment[:transaction_id])

    case transition_type(tx, payment)
    when :initiated_to_preauthorized
      initiated_to_preauthorized(tx)
    when :initiated_to_voided
      delete_transaction(tx)
    else
      # No handler yet, should log but how to get a logger?
    end
  end


  ## Privates

  def transition_type(tx, payment)
    payment_status = payment[:payment_status]
    pending_reason = payment[:pending_reason]
    tx_state = tx[:status]

    case [tx_state, payment_status, pending_reason]
    when ["initiated", :pending, :authorization]
      :initiated_to_preauthorized
    when ["initiated", :voided, :none]
      :initiated_to_voided
    else
      :unknown_transition
    end
  end


  def initiated_to_preauthorized(tx)
    MarketplaceService::Transaction::Command.transition_to(tx[:id], "preauthorized")
  end

  def delete_transaction(tx)
    Transaction.where(community_id: tx[:community_id], id: tx[:id]).destroy_all
  end

end
