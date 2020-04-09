class AddActiveToPaypalAccounts < ActiveRecord::Migration[5.2]
def change
    add_column :paypal_accounts, :active, :boolean, default: false
  end
end
