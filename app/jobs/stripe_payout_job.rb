class StripePayoutJob < Struct.new(:transaction_id, :community_id)

  include DelayedAirbrakeNotification

  # This before hook should be included in all Jobs to make sure that the service_name is
  # correct as it's stored in the thread and the same thread handles many different communities
  # if the job doesn't have host parameter, should call the method with nil, to set the default service_name
  def before(job)
    # Set the correct service name to thread for I18n to pick it
    ApplicationHelper.store_community_service_name_to_thread_from_community_id(community_id)
  end

  def perform
    tx = Transaction.find(transaction_id)
    StripeService::API::Api.payments.payout(tx)
  rescue StandardError => exception
    params_to_airbrake = StripeService::Report.new(tx: tx, exception: exception).create_payout_failed
    error(self, exception, {stripe: params_to_airbrake})
    raise
  end

  def max_attempts
    1
  end
end
