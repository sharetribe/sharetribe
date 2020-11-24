class RemoveTemporaryAccommodationShareTypeFromListings < ActiveRecord::Migration
  def self.up
    Listing.all.each do |listing|
      if listing.share_type.eql?("temporary_accommodation")
        if listing.share_type.is_request?
          listing.update_attribute(:share_type, "rent") 
        else
          listing.update_attribute(:share_type, "rent_out")
        end
      end
    end
  end

  def self.down
  end
end
