class RemoveSsnFromBraintreeAccounts < ActiveRecord::Migration
  def up
    remove_column :braintree_accounts, :ssn
  end

  def down
    add_column :braintree_accounts, :ssn, :string
  end
end
