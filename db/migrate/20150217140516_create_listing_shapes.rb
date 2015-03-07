class CreateListingShapes < ActiveRecord::Migration
  def up
    create_table :listing_shapes do |t|
      t.integer :community_id, null: false
      t.integer :transaction_type_id, null: false
      t.integer :sort_priority, default: nil
      t.boolean :price_enabled, null: false
      t.string :price_quantity_placeholder, default: nil
      t.string :price_per, default: nil
      t.string :url

      t.timestamps null: false
    end

    add_index :listing_shapes, :community_id
    add_index :listing_shapes, :url
  end

  def down
    drop_table :listing_shapes
  end
end
