class ChangeFbConnectDefaultToFalse < ActiveRecord::Migration[5.2]
  def change
    change_column :communities, :facebook_connect_enabled, :boolean, default: false
  end
end
