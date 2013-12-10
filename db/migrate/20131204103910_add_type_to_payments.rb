class AddTypeToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :type, :string, default: "CheckoutPayment"
  end
end
