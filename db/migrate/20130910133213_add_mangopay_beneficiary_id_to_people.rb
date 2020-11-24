class AddMangopayBeneficiaryIdToPeople < ActiveRecord::Migration
  def change
    add_column :people, :mangopay_beneficiary_id, :string unless column_exists? :people, :mangopay_beneficiary_id
  end
end
