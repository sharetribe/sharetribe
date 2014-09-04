# == Schema Information
#
# Table name: community_customizations
#
#  id                                         :integer          not null, primary key
#  community_id                               :integer
#  locale                                     :string(255)
#  name                                       :string(255)
#  slogan                                     :string(255)
#  description                                :text
#  created_at                                 :datetime         not null
#  updated_at                                 :datetime         not null
#  blank_slate                                :text
#  welcome_email_content                      :text
#  how_to_use_page_content                    :text
#  about_page_content                         :text
#  terms_page_content                         :text(16777215)
#  privacy_page_content                       :text
#  storefront_label                           :string(255)
#  signup_info_content                        :text
#  private_community_homepage_content         :text
#  verification_to_post_listings_info_content :text
#  search_placeholder                         :string(255)
#  transaction_agreement_label                :string(255)
#  transaction_agreement_content              :text(16777215)
#
# Indexes
#
#  index_community_customizations_on_community_id  (community_id)
#

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
    :search_placeholder,
    :transaction_agreement_label,
    :transaction_agreement_content

  belongs_to :community
end
