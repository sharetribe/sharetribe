class AddPaymentGatewayToTransaction < ActiveRecord::Migration[5.2]
def change
    add_column :transactions, :payment_gateway, :string, null: false, default: :none
  end
end
