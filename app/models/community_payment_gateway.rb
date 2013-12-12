class CommunityPaymentGateway < ActiveRecord::Base
  
  belongs_to :community
  belongs_to :payment_gateway
  
end
