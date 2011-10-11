class ListingUpdatedJob < Struct.new(:listing_id, :host) 
  
  def perform
    listing = Listing.find(listing_id)
    listing.notify_followers(host, listing.author, true)
  end
  
end