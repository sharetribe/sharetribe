class AddApiVersionToStripeAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :stripe_accounts, :api_version, :string
    add_index :stripe_accounts, :api_version
  end
end
