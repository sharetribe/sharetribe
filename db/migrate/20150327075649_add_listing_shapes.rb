class AddListingShapes < ActiveRecord::Migration
  def change
    create_table :listing_shapes do |t|
      t.integer :community_id, null: false
      t.integer :transaction_process_id, null: false
      t.boolean :price_enabled, null: false
      t.boolean :shipping_enabled, null: false
      t.string :name, null: false
      t.string :name_tr_key, null: false
      t.string :action_button_tr_key, null: false

      t.string :price_quantity_placeholder # temporary
      t.integer :transaction_type_id # temporary

      t.timestamps null: false
    end

    add_index :listing_shapes, :community_id
    add_index :listing_shapes, :name
  end
end
