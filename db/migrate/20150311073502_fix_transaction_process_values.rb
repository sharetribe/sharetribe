class FixTransactionProcessValues < ActiveRecord::Migration
  def up
    execute("
      INSERT INTO transaction_processes (process, author_is_seller, community_id, created_at, updated_at)
      (
        SELECT
          'none',
          1,
          transaction_types.community_id,
          transaction_types.created_at,
          transaction_types.updated_at
        FROM transaction_types

        LEFT JOIN transaction_processes ON (
          transaction_processes.community_id = transaction_types.community_id AND
          transaction_processes.process = 'none' AND
          transaction_processes.author_is_seller = 1)

        WHERE
         transaction_types.type != 'Request' AND
         (transaction_types.price_field IS NULL OR transaction_types.type = 'Inquiry') AND
         transaction_processes.id IS NULL

        GROUP BY community_id, process, author_is_seller
      )
    ")

    execute("
      UPDATE transaction_types

      LEFT JOIN transaction_processes ON (
        transaction_types.community_id = transaction_processes.community_id AND
        transaction_processes.process = 'none' AND
        transaction_processes.author_is_seller = 1
      )

      SET transaction_types.transaction_process_id = transaction_processes.id

      WHERE
        transaction_types.type = 'Inquiry' OR
        transaction_types.price_field IS NULL
    ")

  end

  def down
    # noop
  end
end
