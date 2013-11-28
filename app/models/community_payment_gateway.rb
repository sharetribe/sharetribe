class CommunityPaymentGateway < ActiveRecord::Base
  attr_accessible :braintree_master_merchant_id, :braintree_merchant_id, :braintree_private_key, :braintree_public_key, :community_id, :payment_gateway_id
end
