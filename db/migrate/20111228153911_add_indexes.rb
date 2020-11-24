class AddIndexes < ActiveRecord::Migration
  def self.up
    add_index :communities_listings, [:listing_id, :community_id], :name => "communities_listings"
    add_index :listing_images, :listing_id
    add_index :share_types, :listing_id
    add_index :listings, :listing_type
    add_index :listings, :visibility
    add_index :listings, :open
    add_index :comments, :listing_id
  end

  def self.down
    remove_index :comments, :listing_id
    remove_index :listings, :open
    remove_index :listings, :visibility
    remove_index :listings, :listing_type
    remove_index :share_types, :listing_id
    remove_index :listing_images, :listing_id
    remove_index :communities_listings, :name => :communities_listings
  end
end