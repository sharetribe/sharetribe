class AddFirstNameLastNameToBraintreeAccount < ActiveRecord::Migration
  def change
    add_column :braintree_accounts, :first_name, :string
    add_column :braintree_accounts, :last_name, :string
  end
end
