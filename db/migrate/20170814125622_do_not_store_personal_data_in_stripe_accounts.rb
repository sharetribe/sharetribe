class DoNotStorePersonalDataInStripeAccounts < ActiveRecord::Migration[5.1]
  def change
    remove_column :stripe_accounts, :first_name
    remove_column :stripe_accounts, :last_name
    remove_column :stripe_accounts, :address_country
    remove_column :stripe_accounts, :address_city
    remove_column :stripe_accounts, :address_line1
    remove_column :stripe_accounts, :address_postal_code
    remove_column :stripe_accounts, :address_state
    remove_column :stripe_accounts, :birth_date
    remove_column :stripe_accounts, :bank_account_last_4
    remove_column :stripe_accounts, :stripe_source_info
    remove_column :stripe_accounts, :tos_date
    remove_column :stripe_accounts, :tos_ip
  end
end
