class MoveShareTypesToListing < ActiveRecord::Migration
  def self.up
    Listing.all.each do |listing|
      listing.update_attribute(:share_type, listing.share_types.first.name) unless listing.share_types.empty?
    end
  end

  def self.down
  end
end
