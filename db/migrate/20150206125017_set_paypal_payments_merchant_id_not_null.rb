class SetPaypalPaymentsMerchantIdNotNull < ActiveRecord::Migration[5.2]
def up
    change_column :paypal_payments, :merchant_id, :string, :null => false
  end

  def down
    change_column :paypal_payments, :merchant_id, :string, :null => true
  end
end
