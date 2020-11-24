class MigratePriceQuantityPlaceholderToUnits < ActiveRecord::Migration
  def up
    execute("
      INSERT INTO listing_units (unit_type, quantity_selector, kind, listing_shape_id, created_at, updated_at)
      (
        SELECT 'hour', 'number', 'time', listing_shapes.id, listing_shapes.created_at, listing_shapes.updated_at
        FROM listing_shapes
        WHERE listing_shapes.price_quantity_placeholder = 'time'
      );
    ")
    execute("
      INSERT INTO listing_units (unit_type, quantity_selector, kind, listing_shape_id, created_at, updated_at)
      (
        SELECT 'day', 'number', 'day', listing_shapes.id, listing_shapes.created_at, listing_shapes.updated_at
        FROM listing_shapes
        WHERE listing_shapes.price_quantity_placeholder = 'time'
      );
    ")
    execute("

      INSERT INTO listing_units (unit_type, quantity_selector, kind, listing_shape_id, created_at, updated_at)
      (
        SELECT 'month', 'number', 'time', listing_shapes.id, listing_shapes.created_at, listing_shapes.updated_at
        FROM listing_shapes
        WHERE listing_shapes.price_quantity_placeholder = 'time'
      );
    ")
    execute("

      # long_time ->

      INSERT INTO listing_units (unit_type, quantity_selector, kind, listing_shape_id, created_at, updated_at)
      (
        SELECT 'week', 'number', 'time', listing_shapes.id, listing_shapes.created_at, listing_shapes.updated_at
        FROM listing_shapes
        WHERE listing_shapes.price_quantity_placeholder = 'long_time'
      );
    ")
    execute("

      INSERT INTO listing_units (unit_type, quantity_selector, kind, listing_shape_id, created_at, updated_at)
      (
        SELECT 'month', 'number', 'time', listing_shapes.id, listing_shapes.created_at, listing_shapes.updated_at
        FROM listing_shapes
        WHERE listing_shapes.price_quantity_placeholder = 'long_time'
      );
")
  end

  def down
    execute("
      DELETE listing_units FROM listing_units
      LEFT JOIN listing_shapes ON listing_units.listing_shape_id = listing_shapes.id
      WHERE listing_shapes.price_quantity_placeholder = 'time';
    ")

    execute("
      DELETE listing_units FROM listing_units
      LEFT JOIN listing_shapes ON listing_units.listing_shape_id = listing_shapes.id
      WHERE listing_shapes.price_quantity_placeholder = 'long_time'
")
  end
end
