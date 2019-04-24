class AddTopbarMenuLinksToMarketplaceConfigurations < ActiveRecord::Migration[5.1]
  def change
    add_column :marketplace_configurations, :display_about_menu, :boolean, default: true
    add_column :marketplace_configurations, :display_contact_menu, :boolean, default: true
    add_column :marketplace_configurations, :display_invite_menu, :boolean, default: true
  end
end
