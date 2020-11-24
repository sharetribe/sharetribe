class AddBraintreeEnvironmentToCommunityPaymentGateways < ActiveRecord::Migration
  def change
    add_column :community_payment_gateways, :braintree_environment, :string, :after => :payment_gateway_id
  end
end
