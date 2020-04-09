class RemoveCommunitiesListingsTable < ActiveRecord::Migration[5.2]
  def up
    drop_table "communities_listings"
  end

  def down
    create_table "communities_listings", :id => false do |t|
      t.integer "community_id"
      t.integer "listing_id"
    end
  end
end
