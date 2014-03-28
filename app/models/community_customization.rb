class CommunityCustomization < ActiveRecord::Base

  attr_accessible :community_id,
    :description,
    :locale,
    :name,
    :slogan,
    :blank_slate,
    :welcome_email_content,
    :about_page_content,
    :how_to_use_page_content,
    :terms_page_content,
    :privacy_page_content,
    :storefront_label,
    :signup_info_content,
    :private_community_homepage_content,
    :verification_to_post_listings_info_content,
    :search_placeholder

  has_one :community

end
