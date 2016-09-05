class RemoveOldUnitTypeColumnFromTransactions < ActiveRecord::Migration
  def change
    remove_column :transactions, :old_unit_type, :string, limit: 32, after: :unit_type
  end
end
