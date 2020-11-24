class TransactionPreauthorizedReminderJob < Struct.new(:transaction_id)

  include SessionContextSerializer
  include DelayedAirbrakeNotification

  # This before hook should be included in all Jobs to make sure that the service_name is
  # correct as it's stored in the thread and the same thread handles many different communities
  # if the job doesn't have host parameter, should call the method with nil, to set the default service_name
  def before(job)
    # Set the correct service name to thread for I18n to pick it
    transaction = Transaction.find(transaction_id)
    ApplicationHelper.store_community_service_name_to_thread_from_community_id(transaction.community.id)
  end

  def perform
    transaction = Transaction.find(transaction_id)

    return if Maybe(::PlanService::API::Api.plans.get_current(community_id: transaction.community.id).data)[:expired].or_else(false)

    if transaction.status == "preauthorized"
      MailCarrier.deliver_now(TransactionMailer.transaction_preauthorized_reminder(transaction))
    end
  end
end
