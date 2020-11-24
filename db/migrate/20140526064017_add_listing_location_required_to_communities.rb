class AddListingLocationRequiredToCommunities < ActiveRecord::Migration
  def change
    add_column :communities, :listing_location_required, :boolean, default: false
  end
end
