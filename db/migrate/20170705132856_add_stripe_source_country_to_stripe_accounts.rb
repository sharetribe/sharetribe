class AddStripeSourceCountryToStripeAccounts < ActiveRecord::Migration[5.1]
  def change
    add_column :stripe_accounts, :stripe_source_country, :string
  end
end
