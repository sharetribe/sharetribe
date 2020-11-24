class CreateMarketplaceSettings < ActiveRecord::Migration
  def up
    create_table :marketplace_settings do |t|
      t.column :shipping_enabled, :boolean, default: false
      t.column :community_id, :integer
    end
  end

  def down
    drop_table :marketplace_settings
  end
end
