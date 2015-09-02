class RemoveUnusedListingIndecies < ActiveRecord::Migration
  def up
    remove_index "listings", name: "index_listings_on_listing_type"
    remove_index "listings", name: "index_listings_on_share_type_id"
  end

  def down
    add_index "listings", ["listing_type_old"], :name => "index_listings_on_listing_type"
    add_index "listings", ["share_type_id"], :name => "index_listings_on_share_type_id"
  end
end
