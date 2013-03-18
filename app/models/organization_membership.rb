class OrganizationMembership < ActiveRecord::Base
  attr_accessible :member_id, :organization_id
  attr_protected :admin

  validates_presence_of :member_id
  validates_presence_of :organization_id
  
end
