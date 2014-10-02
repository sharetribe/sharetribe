class MoveDataToTransactionCurrentState < ActiveRecord::Migration
  def up
    execute(<<-EOQ)
      # Get 'last_transition_to_state'
      # (this is done by joining the transitions table to itself where created_at < created_at OR sort_key < sort_key, if created_at equals)
      UPDATE transactions t
      INNER JOIN (
          SELECT tt1.transaction_id, tt1.created_at as last_transition_at, tt1.to_state as last_transition_to_state
          FROM transaction_transitions tt1
          LEFT JOIN transaction_transitions tt2 ON tt1.transaction_id = tt2.transaction_id AND (tt1.created_at < tt2.created_at OR tt1.sort_key < tt2.sort_key OR tt1.id < tt2.id)
          WHERE tt2.id IS NULL
         ) AS tt ON (t.id = tt.transaction_id)
      SET t.current_state = tt.last_transition_to_state
    EOQ
  end

  def down
    execute(<<-EOQ)
      UPDATE transactions SET current_state = NULL
    EOQ
  end
end
