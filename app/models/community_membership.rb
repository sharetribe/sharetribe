class CommunityMembership < ActiveRecord::Base
  
  belongs_to :person
  belongs_to :community
  belongs_to :invitation
  
end
