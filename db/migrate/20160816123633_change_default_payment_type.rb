class ChangeDefaultPaymentType < ActiveRecord::Migration[5.2]
  def up
    change_column :payments, :type, :string, default: "BraintreePayment"
  end

  def down
    change_column :payments, :type, :string, default: "CheckoutPayment"
  end
end
