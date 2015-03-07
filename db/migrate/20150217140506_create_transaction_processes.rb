class CreateTransactionProcesses < ActiveRecord::Migration
  def up
    create_table :transaction_processes do |t|
      t.integer :listing_shape_id, null: false
      t.string :process
      t.boolean :author_is_seller, default: 0

      t.timestamps null: false
    end

    add_index :transaction_processes, :listing_shape_id
  end

  def down
    drop_table :transaction_processes
  end
end
