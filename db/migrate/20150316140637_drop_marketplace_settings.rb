class DropMarketplaceSettings < ActiveRecord::Migration[5.2]
def up
    drop_table :marketplace_settings
  end

  def down
    create_table :marketplace_settings do |t|
      t.column :shipping_enabled, :boolean, default: false
      t.column :community_id, :integer

      t.timestamps
    end
  end
end
