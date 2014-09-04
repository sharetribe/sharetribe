class RenameTransactionTransitionsConversationIdToTransactionId < ActiveRecord::Migration
  def change
    rename_column :transaction_transitions, :conversation_id, :transaction_id
  end
end
