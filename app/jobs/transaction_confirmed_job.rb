class TransactionConfirmedJob < Struct.new(:conversation_id, :community_id)

  include DelayedAirbrakeNotification

  # This before hook should be included in all Jobs to make sure that the service_name is
  # correct as it's stored in the thread and the same thread handles many different communities
  # if the job doesn't have host parameter, should call the method with nil, to set the default service_name
  def before(job)
    # Set the correct service name to thread for I18n to pick it
    ApplicationHelper.store_community_service_name_to_thread_from_community_id(community_id)
  end

  def perform
    transaction = Transaction.find(conversation_id)
    community = Community.find(community_id)
    MailCarrier.deliver_now(PersonMailer.transaction_confirmed(transaction, community))

    if transaction.payment_gateway == "stripe"
      payment = StripeService::Store::StripePayment.get(community_id, transaction.id)
      default_avilable = APP_CONFIG.stripe_payout_delay.to_f.days.from_now
      available_date = (payment[:available_on] || default_available) + 3.hours
      case StripeService::API::Api.wrapper.destination(community_id)
      when :seller then Delayed::Job.enqueue(StripePayoutJob.new(transaction.id, community_id), :priority => 9, :run_at => available_date)
      when :platform then Delayed::Job.enqueue(StripePayoutJob.new(transaction.id, community_id), :priority => 9)
      end
    end
  end
end
