# == Schema Information
#
# Table name: community_customizations
#
#  id                                         :integer          not null, primary key
#  community_id                               :integer
#  locale                                     :string(255)
#  name                                       :string(255)
#  slogan                                     :string(255)
#  description                                :text(65535)
#  created_at                                 :datetime         not null
#  updated_at                                 :datetime         not null
#  blank_slate                                :text(65535)
#  welcome_email_content                      :text(65535)
#  how_to_use_page_content                    :text(16777215)
#  about_page_content                         :text(16777215)
#  terms_page_content                         :text(16777215)
#  privacy_page_content                       :text(16777215)
#  signup_info_content                        :text(65535)
#  private_community_homepage_content         :text(16777215)
#  verification_to_post_listings_info_content :text(16777215)
#  search_placeholder                         :string(255)
#  transaction_agreement_label                :string(255)
#  transaction_agreement_content              :text(16777215)
#
# Indexes
#
#  index_community_customizations_on_community_id  (community_id)
#

class CommunityCustomization < ApplicationRecord

  # Set sane limits for content length. These are either driven by
  # column length in MySQL or, in case of :mediumtext type, set low
  # enough to prevent excess storage usage.
  validates_length_of :blank_slate, maximum: 65535
  validates_length_of :welcome_email_content, maximum: 65535
  validates_length_of :how_to_use_page_content, maximum: 262140
  validates_length_of :about_page_content, maximum: 262140
  validates_length_of :terms_page_content, maximum: 393210
  validates_length_of :privacy_page_content, maximum: 262140
  validates_length_of :signup_info_content, maximum: 65535
  validates_length_of :private_community_homepage_content, maximum: 262140
  validates_length_of :verification_to_post_listings_info_content, maximum: 262140
  validates_length_of :transaction_agreement_label, maximum: 255
  validates_length_of :transaction_agreement_content, maximum: 262140

  belongs_to :community

  CONTENT_FIELDS = %i(
    blank_slate
    welcome_email_content
    how_to_use_page_content
    about_page_content
    terms_page_content
    privacy_page_content
    signup_info_content
    private_community_homepage_content
    verification_to_post_listings_info_content
    search_placeholder
    transaction_agreement_label
    transaction_agreement_content
  )

end
