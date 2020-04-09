class AddIndexTransactionIdShippingAddresses < ActiveRecord::Migration[5.2]
def change
  	add_index :shipping_addresses, [:transaction_id]
  end
end
