class AddIndexTransactionIdShippingAddresses < ActiveRecord::Migration
  def change
  	add_index :shipping_addresses, [:transaction_id]
  end
end
