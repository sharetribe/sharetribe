class CommunityCustomization < ActiveRecord::Base
  
  attr_accessible :community_id, :description, :locale, :slogan, :blank_slate, :welcome_email_content, :about_page_content, :how_to_use_page_content, :terms_page_content, :privacy_page_content, :storefront_label
  
  has_one :community
  
end
