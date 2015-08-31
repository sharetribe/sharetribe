class RemoveOnlyPublicListingsFromCommunities < ActiveRecord::Migration
  def up
    remove_column :communities, :only_public_listings
  end

  def down
    add_column :communities, :only_public_listings, :boolean, default: true, after: :facebook_connect_enabled
  end
end
