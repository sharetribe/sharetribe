class CommunityMembership < ActiveRecord::Base
  
  belongs_to :member, :class_name => "Person", :foreign_key => :member_id
  belongs_to :community
  
end
