class AddFooterStyleToMarketplaceConfigurations < ActiveRecord::Migration[5.1]
  def change
    add_column :marketplace_configurations, :footer_style, :integer, default: 0
  end
end
