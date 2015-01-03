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
end
