class AddMangopayBeneficiaryIdToPeople < ActiveRecord::Migration
  def change
    add_column :people, :mangopay_beneficiary_id, :string
  end
end
