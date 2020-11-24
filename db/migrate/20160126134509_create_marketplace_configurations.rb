class CreateMarketplaceConfigurations < ActiveRecord::Migration
  def change
    create_table :marketplace_configurations do |t|
      t.integer :community_id,    null: false
      t.string  :main_search,     null: false, default: 'keyword'

      t.timestamps null: false
    end

    add_index :marketplace_configurations, :community_id
  end
end
