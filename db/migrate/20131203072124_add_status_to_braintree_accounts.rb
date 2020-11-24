class AddStatusToBraintreeAccounts < ActiveRecord::Migration
  def change
    add_column :braintree_accounts, :status, :string
  end
end
