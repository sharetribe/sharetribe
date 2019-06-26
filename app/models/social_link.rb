# == Schema Information
#
# Table name: social_links
#
#  id            :bigint           not null, primary key
#  community_id  :integer
#  provider      :integer
#  url           :string(255)
#  sort_priority :integer          default(0)
#  enabled       :boolean          default(FALSE)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_social_links_on_community_id  (community_id)
#

class SocialLink < ApplicationRecord
  belongs_to :community

  SOCIAL_NETWORKS = {
    facebook: 0,
    twitter: 1,
    instagram: 2,
    youtube: 3,
    googleplus: 4,
    linkedin: 5,
    pinterest: 6,
    soundcloud: 7
  }.freeze

  enum provider: SOCIAL_NETWORKS

  scope :by_provider, ->(provider) { where(provider: provider) }
  scope :sorted, -> { order('social_links.sort_priority ASC') }
  scope :enabled, -> { where(enabled: true) }

  class << self
    def social_provider_list
      SOCIAL_NETWORKS.keys
    end
  end
end
