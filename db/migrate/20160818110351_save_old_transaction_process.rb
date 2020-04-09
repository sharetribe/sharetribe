class SaveOldTransactionProcess < ActiveRecord::Migration[5.2]
def up
    add_column :transaction_processes, :old_process, :string, limit: 32
    execute "UPDATE transaction_processes SET old_process = process"
  end

  def down
    remove_column :transaction_processes, :old_process
  end
end
