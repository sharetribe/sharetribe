# == Schema Information
#
# Table name: community_plans
#
#  id           :integer          not null, primary key
#  community_id :integer          not null
#  plan_level   :integer          default(0), not null
#  expires_at   :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_community_plans_on_community_id  (community_id)
#

class CommunityPlan < ActiveRecord::Base
  attr_accessible :community_id,
    :plan_level,
    :expires_at
end
