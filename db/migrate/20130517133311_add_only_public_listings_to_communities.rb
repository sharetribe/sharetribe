class AddOnlyPublicListingsToCommunities < ActiveRecord::Migration
  def change
    add_column :communities, :only_public_listings, :boolean, :default => false
  end
end
