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

  validates_presence_of(:community_id)
end
