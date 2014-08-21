class PaypalAccount < ActiveRecord::Base
  belongs_to :merchant, class_name: "Person"
  belongs_to :paypal_payment_gateway

  attr_accessible :username, :api_password, :signature, :merchant, :paypal_payment_gateway

  validates_presence_of :username
  validates_presence_of :api_password
  validates_presence_of :signature

  validate :has_merchant_or_gateway

  def has_merchant_or_gateway
    unless [merchant, paypal_payment_gateway].compact.size == 1
      errors.add(:base, "Exactly one of merchant or paypal payment gateway needs to be present.")
    end
  end
end
