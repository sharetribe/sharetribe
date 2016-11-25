class AddSubMerchantIdAndBraintreeCustomerIdToPeople < ActiveRecord::Migration
  def change
    add_column :people, :sub_merchant_id, :string
    add_column :people, :braintree_customer_id, :string
  end
end
