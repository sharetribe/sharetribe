class AddNewCommunitySettings < ActiveRecord::Migration
  def change
    add_column :communities, :facebook_connect_id, :string
    add_column :communities, :facebook_connect_secret, :string
    add_column :communities, :google_analytics_key, :string
    add_column :communities, :favicon_url, :string
  end
end
