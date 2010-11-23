class ListingCreatedJob < Struct.new(:listing_id, :host) 
  
  def perform
    listing = Listing.find(listing_id)
    listing.author.give_badge("rookie", host) if listing.author.listings.size == 1
    Badge.assign_with_levels("listing_freak", listing.author.listings.open.count, listing.author, [5, 20, 40], host)
    badge_levels = { "lender" => 0, "volunteer" => 0, "taxi_stand" => 0 }
    listing.author.offers.open.each do |offer|
      badge_levels["lender"] += 1 if offer.category.eql?("item") && offer.share_types.collect(&:name).include?("lend")
      badge_levels["volunteer"] += 1 if offer.category.eql?("favor")
    end
    listing.author.offers.each { |offer| badge_levels["taxi_stand"] += 1 if offer.category.eql?("rideshare") }
    badge_levels.each { |badge, level| Badge.assign_with_levels(badge, level, listing.author, [3, 10, 25], host) }
  end
  
end