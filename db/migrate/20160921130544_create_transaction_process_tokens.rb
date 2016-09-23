class CreateTransactionProcessTokens < ActiveRecord::Migration
  def up
    create_table :transaction_process_tokens do |t|
      t.column :community_id, :integer, null: false
      t.column :transaction_id, :integer, null: false
      t.column :op_completed, :boolean, null: false, default: false
      t.column :op_name, :string, limit: 64, null: false
      t.column :op_input, :text
      t.column :op_output, :text

      t.timestamps null: false
    end

    execute "ALTER TABLE transaction_process_tokens ADD process_token BINARY(16) AFTER `id`"

    add_index :transaction_process_tokens, :process_token, unique: true
    add_index :transaction_process_tokens, [:transaction_id, :community_id, :op_name],
              name: "index_paypal_process_tokens_on_transaction", unique: true
  end

  def down
    drop_table :transaction_process_tokens
  end
end
