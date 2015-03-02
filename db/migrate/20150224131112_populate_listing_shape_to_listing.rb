class PopulateListingShapeToListing < ActiveRecord::Migration
  def up
    execute("
      UPDATE listings, listing_shapes, transaction_types
      SET listings.listing_shape_id = listing_shapes.id
      WHERE listing_shapes.transaction_type_id = transaction_types.id
    ")
  end

  def down
    execute("UPDATE listings SET listing_shape_id = NULL")
  end
end
