class RemoveAccountNumberFromBraintreeAccounts < ActiveRecord::Migration
  def up
    remove_column :braintree_accounts, :account_number
  end

  def down
    add_column :braintree_accounts, :account_number, :string
  end
end
