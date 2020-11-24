class DropLandingPageAssets < ActiveRecord::Migration[5.2]
  def up
    drop_table :landing_page_assets
  end

  def down
    create_table :landing_page_assets do |t|
      t.integer :community_id
      t.string :asset_id
      t.attachment :image

      t.timestamps
    end
  end
end
