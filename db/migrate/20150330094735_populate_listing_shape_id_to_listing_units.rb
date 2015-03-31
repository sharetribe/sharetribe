class PopulateListingShapeIdToListingUnits < ActiveRecord::Migration
  def up
    execute("
      UPDATE listing_units
      LEFT JOIN listing_shapes ON (listing_shapes.transaction_type_id = listing_units.transaction_type_id)
      SET listing_units.listing_shape_id = listing_shapes.id")
  end

  def down
    execute("UPDATE listing_units SET listing_shape_id = NULL")
  end
end
