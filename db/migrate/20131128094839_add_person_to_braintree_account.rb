class AddPersonToBraintreeAccount < ActiveRecord::Migration
  def change
    add_column :braintree_accounts, :person_id, :string
  end
end
