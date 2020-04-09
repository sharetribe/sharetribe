class RemoveApiPasswordAndApiSignatureFromPaypalAccounts < ActiveRecord::Migration[5.2]
  def up
    remove_column :paypal_accounts, :api_password
    remove_column :paypal_accounts, :api_signature
  end

  def down
    add_column :paypal_accounts, :api_password, :string
    add_column :paypal_accounts, :api_signature, :string
  end
end
