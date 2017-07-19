class AddConnectFieldsToStripeAccounts < ActiveRecord::Migration[5.1]
  def change
    add_column :stripe_accounts, :access_token, :string
    add_column :stripe_accounts, :refresh_token, :string
  end
end
