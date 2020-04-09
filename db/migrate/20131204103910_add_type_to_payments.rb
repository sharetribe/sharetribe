class AddTypeToPayments < ActiveRecord::Migration[5.2]
def change
    add_column :payments, :type, :string, default: "CheckoutPayment"
  end
end
