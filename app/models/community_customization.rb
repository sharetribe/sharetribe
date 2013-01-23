class CommunityCustomization < ActiveRecord::Base
  
  attr_accessible :community_id, :description, :locale, :slogan
  
  has_one :community
  
end
