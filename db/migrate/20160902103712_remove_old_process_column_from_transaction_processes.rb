class RemoveOldProcessColumnFromTransactionProcesses < ActiveRecord::Migration
  def change
    remove_column :transaction_processes, :old_process, :string, limit: 32, after: :updated_at
  end
end
