class ListingCreatedJob < Struct.new(:listing_id) 
  
  def perform
    listing = Listing.find(listing_id)
    if listing.author.listings.size == 1
      listing.author.give_badge("rookie")
    end   
  end
  
end