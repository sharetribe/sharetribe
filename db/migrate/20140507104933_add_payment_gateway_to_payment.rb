class AddPaymentGatewayToPayment < ActiveRecord::Migration
  def change
    add_column :payments, :payment_gateway_id, :integer, after: :community_id
  end
end
