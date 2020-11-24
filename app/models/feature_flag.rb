# == Schema Information
#
# Table name: feature_flags
#
#  id           :integer          not null, primary key
#  community_id :integer          not null
#  person_id    :string(255)
#  feature      :string(255)      not null
#  enabled      :boolean          default(TRUE), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_feature_flags_on_community_id_and_person_id  (community_id,person_id)
#

class FeatureFlag < ApplicationRecord
  belongs_to :community
  belongs_to :person

  validates_presence_of(:community_id)

  scope :enabled, -> { where(enabled: true) }

  class << self
    def feature_enabled?(community_id, feature)
      enabled.where(community_id: community_id, feature: feature).any?
    end
  end
end
