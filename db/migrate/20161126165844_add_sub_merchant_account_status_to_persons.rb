class AddSubMerchantAccountStatusToPersons < ActiveRecord::Migration
  def change
    add_column :people, :sub_merchant_account_status, :string
  end
end
