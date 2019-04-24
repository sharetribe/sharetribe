class CreateMemberEmailBatchJob < Struct.new(:sender_id, :community_id, :content, :locale, :mode)

  include DelayedAirbrakeNotification

  # This before hook should be included in all Jobs to make sure that the service_name is
  # correct as it's stored in the thread and the same thread handles many different communities
  # if the job doesn't have host parameter, should call the method with nil, to set the default service_name
  def before(job)
    # Set the correct service name to thread for I18n to pick it
    ApplicationHelper.store_community_service_name_to_thread_from_community_id(community_id)
  end

  # This was designed keeping in mind that the number of members is less than 10,000.
  # members.pluck(:id) is more efficient than members.find_each
  def perform
    current_community = Community.where(id: community_id).first

    Delayed::Job.transaction do
      community_members(mode, current_community).pluck(:id).each do |recipient_id|
        Delayed::Job.enqueue(CommunityMemberEmailSentJob.new(sender_id, recipient_id, community_id, content, locale))
      end
    end
  end

  # Here, every SQL query was fine-tuned. If changes are made, please make sure
  # that the SQL queries are executed fast enough.
  def community_members(mode, community)
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
        scope = scope.has_listings(community)
      when :with_listing_no_payment
        scope = scope.has_no_stripe_account(community).has_no_paypal_account(community).has_listings(community)
      when :with_payment_no_listing
        scope = scope.has_payment_account(community).has_no_listings(community)
      when :no_listing_no_payment
        scope = scope.has_no_stripe_account(community).has_no_paypal_account(community).has_no_listings(community)
      when :customers
        scope = scope.has_started_transactions(community)
      else
        scope.none
      end
    else
      scope.none
    end
  end
end
