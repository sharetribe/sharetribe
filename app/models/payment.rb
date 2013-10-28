class Payment < ActiveRecord::Base
  
  include MathHelper
  
  VALID_STATUSES = ["paid", "pending"]
  
  attr_accessible :conversation_id, :payer_id, :recipient_id
  
  belongs_to :conversation
  belongs_to :payer, :class_name => "Person"
  belongs_to :recipient, :class_name => "Person"
  belongs_to :recipient_organization, :class_name => "Organization", :foreign_key => "organization_id"
  belongs_to :community

  validates_inclusion_of :status, :in => VALID_STATUSES
  
  has_many :rows, :class_name => "PaymentRow"
  
  def initialize_rows(community)
    if community.vat
      self.rows = [PaymentRow.new, PaymentRow.new, PaymentRow.new]
    else
      self.rows = [PaymentRow.new]
    end
  end
  
  # Payment excluding VAT and commission
  def sum_without_vat_and_commission
    rows.inject(Money.new(0, rows.first.currency)) { |total, row| total += row.sum }
  end

  # Commission excluding VAT
  def commission_without_vat
    sum_without_vat_and_commission*community.commission_percentage/100
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
    conversation.paid_by!(payer)
    Delayed::Job.enqueue(PaymentCreatedJob.new(id, community.id))
  end
end
