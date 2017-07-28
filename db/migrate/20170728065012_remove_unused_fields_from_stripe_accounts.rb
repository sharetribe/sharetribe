class RemoveUnusedFieldsFromStripeAccounts < ActiveRecord::Migration[5.1]
  def up
    remove_column :stripe_accounts, :account_type

    remove_column :stripe_accounts, :ssn_last_4
    remove_column :stripe_accounts, :personal_id_number
    remove_column :stripe_accounts, :verification_document

    remove_column :stripe_accounts, :charges_enabled
    remove_column :stripe_accounts, :transfers_enabled

    remove_column :stripe_accounts, :stripe_debit_card_id
    remove_column :stripe_accounts, :stripe_debit_card_source
    remove_column :stripe_accounts, :stripe_source_country

    remove_column :stripe_accounts, :access_token
    remove_column :stripe_accounts, :refresh_token
  end
end
