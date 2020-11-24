class UpdateMissingShareTypes < ActiveRecord::Migration
  def up
    Listing.find_each do |listing|
      if listing.share_type.nil? && listing.listing_type_old.present?
        listing.update_column(:share_type_id, ShareType.find_by_name(listing.listing_type_old).id)
      end
    end
  end

  def down
    Listing.find_each do |listing|
      if listing.share_type_old.nil? 
        listing.update_column(:share_type_id, nil)
      end
    end
  end
end
