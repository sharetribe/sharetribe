class PopulateListingShapes < ActiveRecord::Migration
  def up
    execute("
      INSERT INTO listing_shapes (
        community_id,
        transaction_process_id,
        price_enabled,
        shipping_enabled,
        name,
        name_tr_key,
        action_button_tr_key,
        price_quantity_placeholder,
        transaction_type_id,
        created_at,
        updated_at)
      (
        SELECT
          tt.community_id,
          tt.transaction_process_id,
          COALESCE(tt.price_field, false), # Convert NULL to false
          tt.shipping_enabled,
          tt.url,
          tt.name_tr_key,
          tt.action_button_tr_key,
          tt.price_quantity_placeholder,
          tt.id,
          tt.created_at,
          tt.updated_at
        FROM transaction_types AS tt

        LEFT JOIN listing_shapes ON (listing_shapes.transaction_type_id = tt.id)

        WHERE listing_shapes.id IS NULL # Avoid duplicates
      )
")
  end

  def down
    execute("DELETE FROM listing_shapes")
  end
end
