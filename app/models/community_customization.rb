class CommunityCustomization < ActiveRecord::Base
  
  attr_accessible :community_id, :description, :locale, :slogan, :blank_slate, :welcome_email_content
  
  has_one :community
  
end
