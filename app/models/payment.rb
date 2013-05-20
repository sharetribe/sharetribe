class Payment < ActiveRecord::Base
  
  VALID_STATUSES = ["paid", "pending"]
  
  attr_accessible :conversation_id, :payer_id, :recipient_id
  
  belongs_to :conversation
  belongs_to :payer, :class_name => "Person"
  belongs_to :recipient, :class_name => "Person"
  belongs_to :recipient_organization, :class_name => "Organization", :foreign_key => "organization_id"

  validates_inclusion_of :status, :in => VALID_STATUSES
  
  has_many :rows, :class_name => "PaymentRow"
  
  def initialize_rows(community)
    if community.vat
      self.rows = [PaymentRow.new, PaymentRow.new, PaymentRow.new]
    else
      self.rows = [PaymentRow.new]
    end
  end
  
end
