class CreateCategoryListingShapes < ActiveRecord::Migration
  def up
    create_table :category_listing_shapes do |t|
      t.integer :category_id
      t.integer :listing_shape_id

      t.timestamps null: false
    end

    add_index :category_listing_shapes, :category_id
    add_index :category_listing_shapes, :listing_shape_id
  end

  def down
    drop_table :category_listing_shapes
  end
end
