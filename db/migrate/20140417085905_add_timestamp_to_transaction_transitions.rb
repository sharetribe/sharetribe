class AddTimestampToTransactionTransitions < ActiveRecord::Migration[5.2]
def up
    change_table(:transaction_transitions) do |t|
      t.timestamps
    end
  end

  def down
    remove_column :transaction_transitions, :created_at
    remove_column :transaction_transitions, :updated_at
  end
end
