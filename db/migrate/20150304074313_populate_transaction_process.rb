class PopulateTransactionProcess < ActiveRecord::Migration
  def up
    execute("
      INSERT INTO transaction_processes (process, author_is_seller, community_id, created_at, updated_at)
      (
        SELECT
          CASE WHEN transaction_types.price_field = 0                 THEN 'none'
               WHEN transaction_types.type = 'Request'                THEN 'none'
               WHEN payment_settings.id IS NOT NULL                   THEN payment_settings.payment_process
               WHEN payment_gateways.type = 'Checkout'                THEN 'postpay'
               WHEN payment_gateways.type = 'BraintreePaymentGateway' THEN IF(transaction_types.preauthorize_payment, 'preauthorize', 'postpay')
               ELSE 'none'
          END as process,

          CASE WHEN transaction_types.type = 'Request' THEN 0
               ELSE 1
          END as author_is_seller,

          transaction_types.community_id,
          transaction_types.created_at,
          transaction_types.updated_at
        FROM transaction_types

        LEFT JOIN payment_settings ON (payment_settings.community_id = transaction_types.community_id AND payment_settings.active = 1)
        LEFT JOIN payment_gateways ON (payment_gateways.community_id = transaction_types.community_id)

        WHERE transaction_types.transaction_process_id IS NULL
        GROUP BY community_id, process, author_is_seller
      )
    ")

    execute("
      UPDATE transaction_types

      LEFT JOIN payment_settings ON (payment_settings.community_id = transaction_types.community_id AND payment_settings.active = 1)
      LEFT JOIN payment_gateways ON (payment_gateways.community_id = transaction_types.community_id)

      LEFT JOIN transaction_processes ON (
        transaction_types.community_id = transaction_processes.community_id AND

        process =
          CASE WHEN transaction_types.price_field = 0                 THEN 'none'
               WHEN transaction_types.type = 'Request'                THEN 'none'
               WHEN payment_settings.id IS NOT NULL                   THEN payment_settings.payment_process
               WHEN payment_gateways.type = 'Checkout'                THEN 'postpay'
               WHEN payment_gateways.type = 'BraintreePaymentGateway' THEN IF(transaction_types.preauthorize_payment, 'preauthorize', 'postpay')
               ELSE 'none'
          END AND

        author_is_seller =
          CASE WHEN transaction_types.type = 'Request' THEN 0
               ELSE 1
          END
      )

      SET transaction_types.transaction_process_id = transaction_processes.id

      WHERE transaction_process_id IS NULL
  ")

  end

  def down
    execute("DELETE from transaction_processes")
    execute("UPDATE transaction_types SET transaction_process_id = NULL")
  end
end
