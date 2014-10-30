module TransactionService::PaypalEvents

  module_function

  # Paypal payment request was cancelled, remove the associated transaction
  def request_cancelled(token)
    Transaction.where(community_id: token[:community_id], id: token[:transaction_id]).destroy_all
  end

end
