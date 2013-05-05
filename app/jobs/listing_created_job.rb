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
    listing.author.give_badge("rookie", community) if listing.author.listings.size == 1
    Badge.assign_with_levels("listing_freak", listing.author.listings.currently_open.count, listing.author, [5, 20, 40], community)
    badge_levels = { "lender" => 0, "volunteer" => 0, "taxi_stand" => 0 }
    listing.author.offers.currently_open.each do |offer|
      badge_levels["lender"] += 1 if offer.category.top_level_parent.name.eql?("item") && offer.share_type.name.eql?("lend")
      badge_levels["volunteer"] += 1 if offer.category.top_level_parent.name.eql?("favor")
    end
    listing.author.offers.each { |offer| badge_levels["taxi_stand"] += 1 if offer.category.name.eql?("rideshare") }
    badge_levels.each { |badge, level| Badge.assign_with_levels(badge, level, listing.author, [3, 10, 25], community) }
  end
  
end