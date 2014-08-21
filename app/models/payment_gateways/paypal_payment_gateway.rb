class PaypalPaymentGateway < ActiveRecord::Base
  belongs_to :community
  has_one :paypal_account

  attr_accessible :community, :paypal_account

  validates_presence_of :community
end
