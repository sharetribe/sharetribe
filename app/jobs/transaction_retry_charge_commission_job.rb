class TransactionRetryChargeCommissionJob < Struct.new(:transaction_id)

  include DelayedAirbrakeNotification

  def perform
    TransactionService::Transaction.charge_commission_and_retry(transaction_id)
  end
end
