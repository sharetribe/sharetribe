class AddDistanceUnitToMarketplaceConfigurations < ActiveRecord::Migration
  def change
    add_column :marketplace_configurations, :distance_unit, :string, null: false, default: :metric, after: :main_search
  end
end
