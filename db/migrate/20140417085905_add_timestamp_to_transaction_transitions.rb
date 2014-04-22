class AddTimestampToTransactionTransitions < ActiveRecord::Migration
  def change
    change_table(:transaction_transitions) do |t|
      t.timestamps
    end
  end
end
