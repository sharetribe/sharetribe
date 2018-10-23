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
      recipient_ids(mode, current_community).each do |recipient_id|
        Delayed::Job.enqueue(CommunityMemberEmailSentJob.new(sender_id, recipient_id, community_id, content, locale))
      end
    end
  end

  def recipient_ids(mode, community)
    mode_options = Admin::EmailsController::ADMIN_EMAIL_OPTIONS
    mode = mode.to_sym
    if mode_options.include?(mode)
      case mode
      when :all_users
        community.members.map(&:id)
      when :posting_allowed
        community.members.merge(CommunityMembership.posting_allowed).map(&:id)
      when :with_listing
        has_listings_person_ids(community)
      when :with_listing_no_payment
        has_listings_person_ids(community) - paypal_person_ids(community) - stripe_person_ids(community)
      when :with_payment_no_listing
        (paypal_person_ids(community) + stripe_person_ids(community)) - has_listings_person_ids(community)
      when :no_listing_no_payment
        has_no_listings_person_ids(community) - paypal_person_ids(community) - stripe_person_ids(community)
      when :customers
        community.transactions.where(current_state: ['paid', 'confirmed']).select(:starter_id).distinct.map(&:starter_id)
      else
        []
      end
    else
      []
    end
  end

  def paypal_person_ids(community)
    PaypalService::API::Api.accounts.get_active_users(community_id: community.id)
  end

  def stripe_person_ids(community)
    StripeService::API::Api.accounts.get_active_users(community_id: community.id)
  end

  def has_listings_person_ids(community)
    community.members.joins(:listings).distinct.map(&:id)
  end

  def has_no_listings_person_ids(community)
    community.members.left_outer_joins(:listings).where(listings: {author_id: nil}).distinct.map(&:id)
  end
end
