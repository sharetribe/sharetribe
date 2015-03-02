class CategoryTransactionTypesToCategoryListingShapes < ActiveRecord::Migration
  def up
    execute("
      INSERT INTO category_listing_shapes (category_id, listing_shape_id, created_at, updated_at)
      (SELECT
        ctt.category_id, ls.id, ctt.created_at, ctt.updated_at
        FROM category_transaction_types as ctt, listing_shapes as ls
        WHERE (ls.transaction_type_id = ctt.transaction_type_id) AND (ls.id NOT IN (SELECT listing_shape_id FROM category_listing_shapes))
      )
")
  end

  def down
    execute("
      DELETE FROM category_listing_shapes
")
  end
end
