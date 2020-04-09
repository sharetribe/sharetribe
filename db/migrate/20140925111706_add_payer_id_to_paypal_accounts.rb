class AddPayerIdToPaypalAccounts < ActiveRecord::Migration[5.2]
def change
    add_column :paypal_accounts, :payer_id, :string, after: :email
  end
end
