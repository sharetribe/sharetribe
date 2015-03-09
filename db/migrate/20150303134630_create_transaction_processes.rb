class CreateTransactionProcesses < ActiveRecord::Migration
  def change
    create_table :transaction_processes do |t|
      t.string :process, null: false

      t.timestamps
    end
  end
end
