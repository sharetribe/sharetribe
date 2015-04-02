class PopulateCategoryListingShape < ActiveRecord::Migration
  def up
    execute("
      INSERT INTO category_listing_shapes (category_id, listing_shape_id)
      (
        SELECT
          ctt.category_id,
          listing_shapes.id
        FROM category_transaction_types AS ctt

        LEFT JOIN listing_shapes ON (ctt.transaction_type_id = listing_shapes.transaction_type_id)

        # Avoid dublicates
        LEFT JOIN category_listing_shapes ON (ctt.category_id = category_listing_shapes.category_id AND category_listing_shapes.listing_shape_id = listing_shapes.id)
        WHERE category_listing_shapes.listing_shape_id IS NULL
      )
")
  end

  def down
    execute("DELETE FROM category_listing_shapes")
  end
end
