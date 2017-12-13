class DoNotStorePersonalDataInStripeAccounts < ActiveRecord::Migration[5.1]
  def change
    remove_column :stripe_accounts, :first_name, :string
    remove_column :stripe_accounts, :last_name, :string
    remove_column :stripe_accounts, :address_country, :string
    remove_column :stripe_accounts, :address_city, :string
    remove_column :stripe_accounts, :address_line1, :string
    remove_column :stripe_accounts, :address_postal_code, :string
    remove_column :stripe_accounts, :address_state, :string
    remove_column :stripe_accounts, :birth_date, :date
    remove_column :stripe_accounts, :bank_account_last_4, :string
    remove_column :stripe_accounts, :stripe_source_info, :string
    remove_column :stripe_accounts, :tos_date, :datetime
    remove_column :stripe_accounts, :tos_ip, :string
  end
end
