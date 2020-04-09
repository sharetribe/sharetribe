class RenameReadListingsToPersonReadListings < ActiveRecord::Migration[5.2]
  def self.up
    rename_table :read_listings, :person_read_listings
  end

  def self.down
    rename_table :person_read_listings, :read_listings
  end
end
