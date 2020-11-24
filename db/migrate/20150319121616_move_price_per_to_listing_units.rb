class MovePricePerToListingUnits < ActiveRecord::Migration
  def up
    execute("
      INSERT INTO listing_units (unit_type, transaction_type_id, created_at, updated_at)
      (
        SELECT
          'day',
          transaction_types.id,
          transaction_types.created_at,
          transaction_types.updated_at
        FROM transaction_types

        LEFT JOIN listing_units ON (listing_units.transaction_type_id = transaction_types.id)

        WHERE transaction_types.price_field = 1
          AND transaction_types.price_per = 'day'
          AND listing_units.id IS NULL
      )
")
  end

  def down
    execute("
      DELETE FROM listing_units
")
  end
end
