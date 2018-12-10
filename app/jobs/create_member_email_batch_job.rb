class CreateMemberEmailBatchJob < Struct.new(:sender_id, :community_id, :content, :locale, :mode)

  include DelayedAirbrakeNotification

  # This before hook should be included in all Jobs to make sure that the service_name is
  # correct as it's stored in the thread and the same thread handles many different communities
  # if the job doesn't have host parameter, should call the method with nil, to set the default service_name
  def before(job)
    # Set the correct service name to thread for I18n to pick it
    ApplicationHelper.store_community_service_name_to_thread_from_community_id(community_id)
  end

  def perform
    current_community = Community.where(id: community_id).first

    Delayed::Job.transaction do
      members(mode, current_community).find_each do |recipient|
        Delayed::Job.enqueue(CommunityMemberEmailSentJob.new(sender_id, recipient.id, community_id, content, locale))
      end
    end
  end

  def members(mode, community)
    mode_options = Admin::EmailsController::ADMIN_EMAIL_OPTIONS
    mode = mode.to_sym
    scope = community.members
    if mode_options.include?(mode)
      case mode
      when :all_users
        scope
      when :posting_allowed
        scope = scope.merge(CommunityMembership.posting_allowed)
      when :with_listing
        scope = scope.has_listings
      when :with_listing_no_payment
        scope = scope.has_no_stripe_account.has_no_paypal_account.has_listings
      when :with_payment_no_listing
        scope = scope.has_payment_account.has_no_listings
      when :no_listing_no_payment
        scope = scope.has_no_stripe_account.has_no_paypal_account.has_no_listings
      when :customers
        scope = scope.has_started_transactions
      else
        scope.none
      end
    else
      scope.none
    end
  end
end
