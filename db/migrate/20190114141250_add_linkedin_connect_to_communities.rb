class AddLinkedinConnectToCommunities < ActiveRecord::Migration[5.1]
  def change
    add_column :communities, :linkedin_connect_enabled, :boolean
    add_column :communities, :linkedin_connect_id, :string
    add_column :communities, :linkedin_connect_secret, :string
  end
end
