class Payment < ActiveRecord::Base
  
  VALID_STATUSES = ["paid", "pending"]
  
  
  attr_accessible :conversation_id, :payer_id, :recipient_id, :sum
  
  belongs_to :conversation
  belongs_to :payer, :class_name => "Person"
  belongs_to :recipient, :class_name => "Person"
  belongs_to :recipient_organization, :class_name => "Organization", :foreign_key => "organization_id"
  validates_presence_of :sum
  validates_inclusion_of :status, :in => VALID_STATUSES
  
  monetize :sum_cents, :allow_nil => false
  
end
