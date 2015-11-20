# == Schema Information
#
# Table name: facebook_signup_fails
#
#  id           :integer          not null, primary key
#  community_id :integer
#  auth_data    :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class FacebookSignupFails < ActiveRecord::Base
  attr_accessible :auth_data, :community_id
end
