class MigrateTransactionTypeToTransactionProcess < ActiveRecord::Migration
  def up
    execute("
    INSERT INTO transaction_processes (listing_shape_id, process, author_is_seller, created_at, updated_at)
    (
      SELECT
        listing_shapes.id,

        CASE WHEN transaction_types.price_field = 0                THEN 'none'
             WHEN payment_settings.id IS NOT NULL                  THEN payment_settings.payment_process
             WHEN payment_gateways.type = 'Checkout'                THEN 'postpay'
             WHEN payment_gateways.type = 'BraintreePaymentGateway' THEN IF(transaction_types.preauthorize_payment, 'preauthorize', 'postpay')
             ELSE 'none'
        END as process,

        CASE transaction_types.type
          WHEN 'Request' THEN 0
          WHEN 'Inquiry' THEN 0
          ELSE 1
        END author_is_seller,

        listing_shapes.created_at,
        listing_shapes.updated_at
      FROM listing_shapes

      LEFT JOIN transaction_types ON (listing_shapes.transaction_type_id = transaction_types.id)
      LEFT JOIN payment_settings ON (payment_settings.community_id = transaction_types.community_id AND payment_settings.active = 1)
      LEFT JOIN payment_gateways ON (payment_gateways.community_id = listing_shapes.community_id)

      WHERE listing_shapes.id NOT IN (SELECT listing_shape_id FROM transaction_processes)
    )
")
  end

  def down
    execute("DELETE FROM transaction_processes")
  end
end
