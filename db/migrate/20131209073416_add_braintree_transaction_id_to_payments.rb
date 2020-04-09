class AddBraintreeTransactionIdToPayments < ActiveRecord::Migration[5.2]
  def change
    add_column :payments, :braintree_transaction_id, :string
  end
end
