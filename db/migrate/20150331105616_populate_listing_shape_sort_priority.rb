class PopulateListingShapeSortPriority < ActiveRecord::Migration
  def up
    execute("
      UPDATE listing_shapes
      LEFT JOIN transaction_types ON (transaction_types.id = listing_shapes.transaction_type_id)
      SET listing_shapes.sort_priority = COALESCE(transaction_types.sort_priority, 0) # Convert NULL to 0
    ")
  end

  def down
    execute("
      UPDATE listing_shapes SET sort_priority = 0
    ")
  end
end
