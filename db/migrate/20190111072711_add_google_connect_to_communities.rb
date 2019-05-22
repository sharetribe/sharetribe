class AddGoogleConnectToCommunities < ActiveRecord::Migration[5.1]
  def change
    add_column :communities, :google_connect_enabled, :boolean
    add_column :communities, :google_connect_id, :string
    add_column :communities, :google_connect_secret, :string
  end
end
