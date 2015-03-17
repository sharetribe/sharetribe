class RemoveMultiCommunityListings < ActiveRecord::Migration

  # Warning: This migration deletes data. Take backups.
  #
  # Background: Earlier versions of Sharetribe supported posting the same listing
  # to multiple marketplaces. This functionality has been removed long ago. However,
  # the existing data from communities_listings has not been removed.
  #
  # This migration deletes all but one community - listing relations from listings
  # that belong to multiple communities. We use community_id from transaction_type to
  # define the original community, in which the listing was created.
  #
  def up
    execute("
      DELETE communities_listings FROM communities_listings
      LEFT JOIN listings ON (communities_listings.listing_id = listings.id)
      LEFT JOIN transaction_types ON (listings.transaction_type_id = transaction_types.id)
      WHERE communities_listings.community_id <> transaction_types.community_id
    ")
  end

  def down
    # This migration deletes data, so no way to down migrate it in anyway.
  end
end
