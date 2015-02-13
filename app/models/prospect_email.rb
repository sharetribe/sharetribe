# == Schema Information
#
# Table name: prospect_emails
#
#  id         :integer          not null, primary key
#  email      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ProspectEmail < ActiveRecord::Base
  attr_accessible :email
end
