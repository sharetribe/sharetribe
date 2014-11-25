# conversation_id should be transaction_id, but hard to migrate due to existing job descriptions in DB
class PaymentReminderJob < Struct.new(:conversation_id, :recipient_id, :community_id)

  include DelayedAirbrakeNotification

  # This before hook should be included in all Jobs to make sure that the service_name is
  # correct as it's stored in the thread and the same thread handles many different communities
  # if the job doesn't have community_id parameter, should call the method with nil, to set the default service_name
  def before(job)
    # Set the correct service name to thread for I18n to pick it
    ApplicationHelper.store_community_service_name_to_thread_from_community_id(community_id)
  end

  def perform
    transaction = Transaction.find(conversation_id)
    community = Community.find(community_id)
    can_transition_to_paid = MarketplaceService::Transaction::Query.can_transition_to?(transaction.id, :paid)

    if can_transition_to_paid && transaction.payment.status.eql?("pending")
      PersonMailer.send("payment_reminder", transaction, transaction.payment.payer, community).deliver
    end
  end

end
