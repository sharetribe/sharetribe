class ChangePersonIdStripeAccounts < ActiveRecord::Migration[5.1]
  def change
    change_column :stripe_accounts, :person_id, :string, :null => false
  end
end
