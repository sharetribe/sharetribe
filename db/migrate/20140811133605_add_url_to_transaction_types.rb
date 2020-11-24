class AddUrlToTransactionTypes < ActiveRecord::Migration
  def change
    add_column :transaction_types, :url, :string, :nil => false
    add_index :transaction_types, :url, :unique => false
  end
end