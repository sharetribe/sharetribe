class AddPaymentGatewayToTransaction < ActiveRecord::Migration
  def change
    add_column :transactions, :payment_gateway, :string, null: false, default: :none
  end
end
