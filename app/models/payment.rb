# == Schema Information
#
# Table name: payments
#
#  id                       :integer          not null, primary key
#  payer_id                 :string(255)
#  recipient_id             :string(255)
#  organization_id          :string(255)
#  conversation_id          :integer
#  status                   :string(255)
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  community_id             :integer
#  payment_gateway_id       :integer
#  sum_cents                :integer
#  currency                 :string(255)
#  type                     :string(255)      default("CheckoutPayment")
#  braintree_transaction_id :string(255)
#
# Indexes
#
#  index_payments_on_conversation_id  (conversation_id)
#  index_payments_on_payer_id         (payer_id)
#

class Payment < ActiveRecord::Base

  include MathHelper

  VALID_STATUSES = ["paid", "pending", "disbursed"]

  attr_accessible :conversation_id, :payer_id, :recipient_id

  belongs_to :conversation
  belongs_to :payer, :class_name => "Person"
  belongs_to :recipient, :class_name => "Person"

  belongs_to :community
  belongs_to :payment_gateway

  validates_inclusion_of :status, :in => VALID_STATUSES
  validate :validate_sum

  delegate :commission_from_seller, to: :community
  delegate :gateway_commission_percentage, :gateway_commission_fixed, :no_fixed_commission, to: :payment_gateway

  def validate_sum
    unless sum_exists?
      errors.add(:base, "Payment is not valid without sum")
    end
  end

  def paid!
    update_attribute(:status, "paid")
  end

  def disbursed!
    update_attribute(:status, "disbursed")
    # Notification here?
  end

  def total_commission_percentage
    (Maybe(commission_from_seller).or_else(0) + Maybe(gateway_commission_percentage).or_else(0)).to_f / 100.to_f
  end

  def total_commission_fixed
    # Currently no marketplace specific fixed part
    gateway_commission_fixed || no_fixed_commission
  end

  def total_commission
    commission = total_sum * total_commission_percentage + total_commission_fixed
    Money.new(PaymentMath.ceil_cents(commission.cents), commission.currency)
  end

  def seller_gets
    total_sum - total_commission
  end

  def total_commission_without_vat
    vat = Maybe(community).vat.or_else(0).to_f / 100.to_f
    total_commission / (1 + vat)
  end

  # How many days until the preauthorized payment is automatically
  # rejected
  def preauthorization_expiration_days
    5
  end
end
