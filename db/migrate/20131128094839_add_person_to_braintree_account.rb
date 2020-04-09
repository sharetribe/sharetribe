class AddPersonToBraintreeAccount < ActiveRecord::Migration[5.2]
def change
    add_column :braintree_accounts, :person_id, :string
  end
end
