class CreateTransactionProcesses < ActiveRecord::Migration
  def change
    create_table :transaction_processes do |t|
      t.integer :community_id
      t.string :process, null: false, limit: 32
      t.boolean :author_is_seller

      t.timestamps
    end
  end
end
