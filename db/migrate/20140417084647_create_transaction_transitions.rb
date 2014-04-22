class CreateTransactionTransitions < ActiveRecord::Migration
  def change
    create_table :transaction_transitions do |t|
      t.string :to_state
      t.text :metadata
      t.integer :sort_key, default: 0
      t.integer :conversation_id
    end

    add_index :transaction_transitions, :conversation_id
    add_index :transaction_transitions, [:sort_key, :conversation_id], unique: true
  end
end
