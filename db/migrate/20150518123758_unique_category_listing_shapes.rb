class UniqueCategoryListingShapes < ActiveRecord::Migration
  def up
    remove_index :category_listing_shapes, name: "index_listing_shape_category_joins"

    add_index :category_listing_shapes, [:listing_shape_id, :category_id], name: "unique_listing_shape_category_joins", unique: true
  end

  def down
    remove_index :category_listing_shapes, name: "unique_listing_shape_category_joins"

    add_index :category_listing_shapes, [:listing_shape_id, :category_id], name: "index_listing_shape_category_joins"
  end

end
