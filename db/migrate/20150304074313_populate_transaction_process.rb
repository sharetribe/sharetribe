class PopulateTransactionProcess < ActiveRecord::Migration
  def up
    add_column :transaction_processes, :transaction_type_id, :int

    execute("
      INSERT INTO transaction_processes (process, transaction_type_id, created_at, updated_at)
      (
        SELECT
          CASE WHEN transaction_types.price_field = 0                 THEN 'none'
               WHEN payment_settings.id IS NOT NULL                   THEN payment_settings.payment_process
               WHEN payment_gateways.type = 'Checkout'                THEN 'postpay'
               WHEN payment_gateways.type = 'BraintreePaymentGateway' THEN IF(transaction_types.preauthorize_payment, 'preauthorize', 'postpay')
               ELSE 'none'
          END as process,
          transaction_types.id,
          transaction_types.created_at,
          transaction_types.updated_at
        FROM transaction_types

        LEFT JOIN payment_settings ON (payment_settings.community_id = transaction_types.community_id AND payment_settings.active = 1)
        LEFT JOIN payment_gateways ON (payment_gateways.community_id = transaction_types.community_id)

        WHERE transaction_types.transaction_process_id IS NULL
      )
    ")

    execute("
     UPDATE transaction_types, transaction_processes
     SET transaction_types.transaction_process_id = transaction_processes.id
     WHERE transaction_processes.transaction_type_id = transaction_types.id")

    remove_column :transaction_processes, :transaction_type_id
  end

  def down
    execute("DELETE from transaction_processes")
    execute("UPDATE transaction_types SET transaction_process_id = NULL")
  end
end
