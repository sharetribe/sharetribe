class AddMerchantKeyToPeople < ActiveRecord::Migration
  def change
    add_column :people, :checkout_merchant_key, :string
  end
end
