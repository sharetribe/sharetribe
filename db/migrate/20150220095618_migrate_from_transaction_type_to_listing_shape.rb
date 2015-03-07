class MigrateFromTransactionTypeToListingShape < ActiveRecord::Migration
  def up
    execute("
      INSERT INTO listing_shapes
      (community_id, transaction_type_id, sort_priority, price_enabled, price_quantity_placeholder, price_per, url, created_at, updated_at)
      (SELECT community_id, id, sort_priority, price_field, price_quantity_placeholder, price_per, url, created_at, updated_at FROM transaction_types
       WHERE id NOT IN (SELECT transaction_type_id FROM listing_shapes))
    ")
  end

  def down
    execute("
      DELETE FROM listing_shapes
    ")
  end
end
