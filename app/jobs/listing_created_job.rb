class ListingCreatedJob < Struct.new(:listing_id, :host) 
  
  def perform
    listing = Listing.find(listing_id)
    listing.author.give_badge("rookie", host) if listing.author.listings.size == 1
    Badge.assign_with_levels("listing_freak", listing.author.listings.open.count, listing.author, [5, 25, 50], host)
  end
  
end