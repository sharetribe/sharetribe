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
  validate :one_conversation_cannot_have_multiple_payments

  # There can be only one payment related to a certain conversation
  def one_conversation_cannot_have_multiple_payments
    payments = Payment.where(:conversation_id => conversation.id)
    if payments.size > 1 || (payments.size == 1 && payments.first.id != self.id)
      errors.add(:base, "An invoice exists already for this conversation")
    end
  end

  def validate_sum
    unless sum_exists?
      errors.add(:base, "Payment is not valid without sum")
    end
  end

  def paid!
    update_attribute(:status, "paid")
    conversation.status = "paid"
    Delayed::Job.enqueue(PaymentCreatedJob.new(id, community.id))
  end

  def disbursed!
    update_attribute(:status, "disbursed")
    # Notification here?
  end

  def total_commission_percentage
    community_commission_percentage + gateway_commission_percentage
  end

  def total_commission_fixed
    # Currently no marketplace specific fixed part
    gateway_commission_fixed
  end
end
