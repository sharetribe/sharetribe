class CreateMemberEmailBatchJob < Struct.new(:sender_id, :community_id, :subject, :content, :locale, :mode)

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

    recipient_scope = if mode == 'admins'
                        current_community.admins
                      else
                        current_community.members
                      end

    recipient_scope.find_in_batches(batch_size: 1000) do |member_group|
      Delayed::Job.transaction do
        member_group.each do |recipient|
          if mode != 'all' && matches_mode?(mode, current_community, recipient)
            Delayed::Job.enqueue(CommunityMemberEmailSentJob.new(sender_id, recipient.id, community_id, subject, content, locale))
          end
        end
      end
    end
  end

  def matches_mode?(mode, community, recipient)
    has_listings = recipient.listings.exists?

    paypal_ready = PaypalHelper.user_and_community_ready_for_payments?(recipient.id, community.id)

    # TODO: remove rescue after merge with stripe-integration
    begin
      stripe_ready = StripeHelper.user_and_community_ready_for_payments?(recipient.id, community.id)
    rescue
      stripe_mode = nil
    end

    case mode
    when 'with_listing'
      has_listings
    when 'with_listing_no_payment'
      has_listings && !(paypal_ready || stripe_ready)
    when 'with_payment_no_listing'
      (paypal_ready || stripe_ready) && !has_listings
    when 'no_listing_no_payment'
      !(paypal_ready || stripe_ready) && !has_listings
    when 'customers'
      Transaction.where(starter_id: recipient.id, current_state: ['paid', 'confirmed'], community_id: community.id).exists?
    else
      true
    end
  end
end
