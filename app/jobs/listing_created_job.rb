class ListingCreatedJob < Struct.new(:listing_id, :community_id)

  include DelayedAirbrakeNotification

  # This before hook should be included in all Jobs to make sure that the service_name is
  # correct as it's stored in the thread and the same thread handles many different communities
  # if the job doesn't have community_id parameter, should call the method with nil, to set the default service_name
  def before(job)
    # Set the correct service name to thread for I18n to pick it
    ApplicationHelper.store_community_service_name_to_thread_from_community_id(community_id)
  end

  def perform
    listing = Listing.find(listing_id)
    community = Community.find(community_id)
    # Send reminder about missing payment information
    if MarketplaceService::Listing::Entity.send_payment_settings_reminder?(listing_id, community_id)
      PersonMailer.payment_settings_reminder(listing, listing.author, community).deliver
    end
  end

end
