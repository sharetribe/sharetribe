class PopulateListingsCommunityId < ActiveRecord::Migration[5.2]
  def up
    execute("
      UPDATE listings
      LEFT JOIN communities_listings ON (listings.id = communities_listings.listing_id)
      SET listings.community_id = communities_listings.community_id
    ")
  end

  def down
    execute("UPDATE listings SET community_id = NULL")
  end
end
