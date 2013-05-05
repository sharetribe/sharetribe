class AddFacebookConnectEnabledToCommunities < ActiveRecord::Migration
  def change
    add_column :communities, :facebook_connect_enabled, :boolean, :default => true
  end
end
