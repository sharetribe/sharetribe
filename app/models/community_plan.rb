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

class CommunityPlan < ActiveRecord::Base

  attr_accessible :community_id,
    :plan_level,
    :expires_at

  belongs_to :community

  # Plan levels
  FREE_PLAN = 0
  STARTER_PLAN = 1
  BASIC_PLAN = 2
  GROWTH_PLAN = 3
  SCALE_PLAN = 4

end
