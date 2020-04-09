class AddListingLocationRequiredToCommunities < ActiveRecord::Migration[5.2]
def change
    add_column :communities, :listing_location_required, :boolean, default: false
  end
end
