class SendNewTransactionEmail < Struct.new(:transaction_id)

  include DelayedAirbrakeNotification

  # Set the correct service name to thread for I18n to pick it
  def before(job)
    transaction = Transaction.find(transaction_id)
    ApplicationHelper.store_community_service_name_to_thread_from_community_id(transaction.community_id)
  end

  def perform
    transaction = Transaction.find(transaction_id)
    transaction.community.admins.each do |admin|
      TransactionMailer.new_transaction(transaction, admin).deliver_now
    end
  end
end
