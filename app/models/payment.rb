class Payment < ActiveRecord::Base

  include MathHelper

  VALID_STATUSES = ["paid", "pending", "disbursed"]

  attr_accessible :conversation_id, :payer_id, :recipient_id, :braintree_transaction_id

  belongs_to :conversation
  belongs_to :payer, :class_name => "Person"
  belongs_to :recipient, :class_name => "Person"

  belongs_to :community

  has_many :rows, :class_name => "PaymentRow"

  monetize :sum_cents, :allow_nil => true

  validates_inclusion_of :status, :in => VALID_STATUSES
  validate :sum_exists
  validate :one_conversation_cannot_have_multiple_payments

  # There can be only one payment related to a certain conversation
  def one_conversation_cannot_have_multiple_payments
    payments = Payment.where(:conversation_id => conversation.id)
    if payments.size > 1 || (payments.size == 1 && payments.first.id != self.id)
      errors.add(:base, "An invoice exists already for this conversation")
    end
  end

  # Payment must have either sum or at least one row
  def sum_exists
    if rows.empty? && !sum_cents
      errors.add(:base, "Payment is not valid without sum")
    end
  end

  def initialize_rows(community)
    if community.vat
      self.rows = [PaymentRow.new, PaymentRow.new, PaymentRow.new]
    else
      self.rows = [PaymentRow.new]
    end
  end

  # Payment excluding VAT and commission
  def sum_without_vat_and_commission
    rows.empty? ? sum : rows.inject(Money.new(0, rows.first.currency)) { |total, row| total += row.sum }
  end

  # Commission excluding VAT
  def commission_without_vat
    throw "Comission percentage has to be set" unless community.commission_from_seller
    sum_without_vat_and_commission*community.commission_from_seller/100
  end

  # Commission including VAT
  def total_commission
    sum_with_percentage(commission_without_vat, APP_CONFIG.service_fee_tax_percentage.to_i)
  end

  # Total payment with VAT but without commission
  def sum_without_commission
    rows.inject(Money.new(0, rows.first.currency)) { |total, row| total += row.sum_with_vat }
  end

  # Total payment that will be charged from the payer's account
  def total_sum
    sum_without_commission + total_commission
  end

  def summary_string
    rows.collect(&:title).join(", ")
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
end
