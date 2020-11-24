class PopulateUnitTypeToListing < ActiveRecord::Migration
  def up
    execute("
      UPDATE listings
      LEFT JOIN listing_units ON (listings.transaction_type_id = listing_units.transaction_type_id)
      SET listings.unit_type = listing_units.unit_type
      WHERE listing_units.unit_type IS NOT NULL
    ")
  end

  def down
    execute("UPDATE listings SET listings.unit_type = NULL")
  end
end
