class RemoveAccountNumberFromBraintreeAccounts < ActiveRecord::Migration[5.2]
def up
    remove_column :braintree_accounts, :account_number
  end

  def down
    add_column :braintree_accounts, :account_number, :string
  end
end
