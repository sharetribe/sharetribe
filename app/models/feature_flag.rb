# == Schema Information
#
# Table name: feature_flags
#
#  id           :integer          not null, primary key
#  community_id :integer          not null
#  shape_ui     :boolean          default(FALSE), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_feature_flags_on_community_id  (community_id)
#

class FeatureFlag < ActiveRecord::Base
  attr_accessible(:community_id, :shape_ui)

  validates_presence_of(:community_id)
end
