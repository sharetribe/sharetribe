class CommunityMembership < ActiveRecord::Base
  
  belongs_to :person
  belongs_to :community
  
end
