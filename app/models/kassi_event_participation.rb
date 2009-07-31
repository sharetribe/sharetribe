class KassiEventParticipation < ActiveRecord::Base
  
  belongs_to :person
  belongs_to :kassi_event
  
  VALID_ROLES = ["requester", "provider", "none", "buyer", "seller"]
  
  validates_inclusion_of :role, :in => VALID_ROLES
  
end
