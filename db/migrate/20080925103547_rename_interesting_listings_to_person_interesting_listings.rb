class RenameInterestingListingsToPersonInterestingListings < ActiveRecord::Migration[5.2]
def self.up
    rename_table :interesting_listings, :person_interesting_listings
  end

  def self.down
    rename_table :person_interesting_listings, :interesting_listings
  end
end
