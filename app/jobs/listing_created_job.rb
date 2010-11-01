class ListingCreatedJob < Struct.new(:listing_id, :host) 
  
  def perform
    listing = Listing.find(listing_id)
    if listing.author.listings.size == 1
      listing.author.give_badge("rookie", host)
    end   
  end
  
end