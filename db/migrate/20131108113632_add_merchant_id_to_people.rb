class AddMerchantIdToPeople < ActiveRecord::Migration[5.2]
def change
    add_column :people, :checkout_merchant_id, :string
  end
end
