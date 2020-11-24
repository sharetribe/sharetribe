class RemovePriceFromListingsWithoutPriceField < ActiveRecord::Migration
  def up
    execute("
      UPDATE listings
      LEFT JOIN transaction_types ON (listings.transaction_type_id = transaction_types.id)
      SET price_cents = NULL, currency = NULL
      WHERE transaction_types.price_field != 1
")
  end

  def down
    #noop
  end
end
