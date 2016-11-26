class AddSubMerchantAccountStatusToPersons < ActiveRecord::Migration
  def change
    add_column :persons, :sub_merchant_account_status, :string
  end
end
