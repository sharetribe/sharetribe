class AddMerchantIdToPeople < ActiveRecord::Migration
  def change
    add_column :people, :checkout_merchant_id, :string
  end
end
