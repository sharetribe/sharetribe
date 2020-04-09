class ChangeTransactionIdToTransactionTypeId < ActiveRecord::Migration[5.2]
def change
    rename_column :listings, :transaction_id, :transaction_type_id
  end
end
