class RemoveTypeFromTransactionTypes < ActiveRecord::Migration
  def up
    remove_column :transaction_types, :type
  end

  def down
    add_column :transaction_types, :type, :string, after: :id
  end
end
