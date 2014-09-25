class AddPayerIdToPaypalAccounts < ActiveRecord::Migration
  def change
    add_column :paypal_accounts, :payer_id, :string, after: :email
  end
end
