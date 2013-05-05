class OrganizationMembership < ActiveRecord::Base
  
  belongs_to :person
  belongs_to :organization
  attr_accessible :person_id, :organization_id
  attr_protected :admin

  validates_presence_of :person_id
  validates_presence_of :organization_id
  
end
