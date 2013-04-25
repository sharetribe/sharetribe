class AddTransactionTypeToShareTypes < ActiveRecord::Migration
  def change
    add_column :share_types, :transaction_type, :string
  end
end
