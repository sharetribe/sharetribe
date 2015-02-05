class AddMerchantIdToPaypalPayments < ActiveRecord::Migration
  def change
    add_column :paypal_payments, :merchant_id, :string, null: false, after: :receiver_id
  end
end
