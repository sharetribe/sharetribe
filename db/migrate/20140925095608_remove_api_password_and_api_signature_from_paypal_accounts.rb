class RemoveApiPasswordAndApiSignatureFromPaypalAccounts < ActiveRecord::Migration
  def up
    remove_column :paypal_accounts, :api_password
    remove_column :paypal_accounts, :api_signature
  end

  def down
    add_column :paypal_accounts, :api_password, :string
    add_column :paypal_accounts, :api_signature, :string
  end
end
