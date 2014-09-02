class RemoveMangopayFromPeople < ActiveRecord::Migration
  def up
    remove_column :people, :mangopay_id, :mangopay_beneficiary_id, :bic, :bank_account_owner_name, :iban, :bank_account_owner_address
  end

  def down
    add_column :people, :mangopay_id, :string
    add_column :people, :bic, :string
    add_column :people, :bank_account_owner_name, :string
    add_column :people, :iban, :string
    add_column :people, :bank_account_owner_address, :string
    add_column :people, :mangopay_beneficiary_id, :string
  end
end
