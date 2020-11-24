# == Schema Information
#
# Table name: landing_pages
#
#  id               :integer          not null, primary key
#  community_id     :integer          not null
#  enabled          :boolean          default(FALSE), not null
#  released_version :integer
#  updated_at       :datetime
#
# Indexes
#
#  index_landing_pages_on_community_id  (community_id) UNIQUE
#

class LandingPage < ApplicationRecord
  belongs_to :community

  scope :enabled, -> { where(enabled: true) }

  class << self
    def released_version(community)
      where(community: community).enabled.pluck(:released_version).first
    end
  end
end
