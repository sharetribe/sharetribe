class RemoveDuplicateCategoryListingShapes < ActiveRecord::Migration
  def up
    add_column :category_listing_shapes, :temp_id, :primary_key

    execute("
      DELETE category_listing_shapes
      FROM category_listing_shapes
      LEFT OUTER JOIN (
        SELECT MIN(temp_id) as temp_id, category_id, listing_shape_id
        FROM category_listing_shapes
        GROUP BY category_id, listing_shape_id
      ) AS keep_rows ON (
        category_listing_shapes.temp_id = keep_rows.temp_id
      )
      WHERE keep_rows.temp_id IS NULL
    ")

    remove_column :category_listing_shapes, :temp_id
  end

  def down
    # noop
  end
end
