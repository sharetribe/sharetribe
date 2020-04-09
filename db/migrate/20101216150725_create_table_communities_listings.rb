class CreateTableCommunitiesListings < ActiveRecord::Migration[5.2]
  def self.up
    create_table :communities_listings, :id => false do |t|
      t.integer :community_id
      t.integer :listing_id
    end
  end

  def self.down
    drop_table :communities_listings
  end
end
