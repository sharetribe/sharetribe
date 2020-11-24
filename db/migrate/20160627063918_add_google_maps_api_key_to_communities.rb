class AddGoogleMapsApiKeyToCommunities < ActiveRecord::Migration
  def change
    add_column :communities, :google_maps_key, :string, limit: 64, after: :google_analytics_key
  end
end
