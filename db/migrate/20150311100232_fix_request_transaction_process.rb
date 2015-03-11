class FixRequestTransactionProcess < ActiveRecord::Migration
  def up
    execute("
      UPDATE transaction_types

      LEFT JOIN transaction_processes ON (
        transaction_types.community_id = transaction_processes.community_id AND
        transaction_processes.process = 'none' AND
        transaction_processes.author_is_seller = 0
      )

      SET transaction_types.transaction_process_id = transaction_processes.id

      WHERE
        transaction_types.type = 'Request'
    ")
  end

  def down
    #noop
  end
end
