class AddPayoutDetailsToPeople < ActiveRecord::Migration
  def change
    add_column :people, :bank_account_owner_name, :string
    add_column :people, :bank_account_owner_address, :string
    add_column :people, :iban, :string
    add_column :people, :bic, :string
  end
end
