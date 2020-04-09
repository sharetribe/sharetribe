class AddPaymentGatewayToPayment < ActiveRecord::Migration[5.2]
def change
    add_column :payments, :payment_gateway_id, :integer, after: :community_id
  end
end
