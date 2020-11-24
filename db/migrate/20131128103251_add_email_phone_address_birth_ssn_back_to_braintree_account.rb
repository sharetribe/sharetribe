class AddEmailPhoneAddressBirthSsnBackToBraintreeAccount < ActiveRecord::Migration
  def change
    add_column :braintree_accounts, :email, :string
    add_column :braintree_accounts, :phone, :string
    add_column :braintree_accounts, :address_street_address, :string
    add_column :braintree_accounts, :address_postal_code, :string
    add_column :braintree_accounts, :address_locality, :string
    add_column :braintree_accounts, :address_region, :string
    add_column :braintree_accounts, :date_of_birth, :string
    add_column :braintree_accounts, :ssn, :string
    add_column :braintree_accounts, :routing_number, :string
    add_column :braintree_accounts, :account_number, :string
  end
end
