class MoveLastTransitionDataToTransactions < ActiveRecord::Migration
  def up
    execute(<<-EOQ)
      # Get 'last_transition_at'
      # (this is done by joining the transitions table to itself where created_at < created_at OR sort_key < sort_key, if created_at equals)
      UPDATE transactions t
      INNER JOIN (
          SELECT tt1.transaction_id, tt1.created_at as last_transition_at
          FROM transaction_transitions tt1
          LEFT JOIN transaction_transitions tt2 ON tt1.transaction_id = tt2.transaction_id AND (tt1.created_at < tt2.created_at OR tt1.sort_key < tt2.sort_key OR tt1.id < tt2.id)
          WHERE tt2.id IS NULL
         ) AS tt ON (t.id = tt.transaction_id)
      SET t.last_transition_at = tt.last_transition_at
    EOQ
  end

  def down
    execute(<<-EOQ)
      UPDATE transactions SET last_transition_at = NULL
    EOQ
  end
end
