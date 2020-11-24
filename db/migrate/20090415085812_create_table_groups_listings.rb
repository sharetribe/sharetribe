class CreateTableGroupsListings < ActiveRecord::Migration
  def self.up
    create_table :groups_listings, :id => false do |t|
      t.string :group_id
      t.integer :listing_id
    end
  end

  def self.down
    drop_table :groups_listings
  end
end
