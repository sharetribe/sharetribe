class RemoveUnitsFromShapeWithoutPrice < ActiveRecord::Migration
  def up
    execute("
      DELETE listing_units FROM listing_units
      LEFT JOIN listing_shapes ON listing_units.listing_shape_id = listing_shapes.id
      WHERE listing_shapes.price_enabled = 0
    ")
  end

  def down
    # Nothing
  end
end
