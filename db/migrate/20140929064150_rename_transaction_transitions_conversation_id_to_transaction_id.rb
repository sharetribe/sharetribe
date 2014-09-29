class RenameTransactionTransitionsConversationIdToTransactionId < ActiveRecord::Migration
  def up
    rename_column :transaction_transitions, :conversation_id, :transaction_id
  end

  def down
    execute("UPDATE transaction_transitions
      INNER JOIN transactions ON (transaction_transitions.transaction_id = transactions.id)
      SET transaction_id = transactions.conversation_id")

    rename_column :transaction_transitions, :transaction_id, :conversation_id
  end
end
