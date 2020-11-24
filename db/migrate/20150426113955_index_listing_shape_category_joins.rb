class IndexListingShapeCategoryJoins < ActiveRecord::Migration
  def change
    add_index "category_listing_shapes", ["listing_shape_id", "category_id"], name: "index_listing_shape_category_joins"
  end
end
