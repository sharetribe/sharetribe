class ChangeTransactionIdToTransactionTypeId < ActiveRecord::Migration
  def change
    rename_column :listings, :transaction_id, :transaction_type_id
  end
end
