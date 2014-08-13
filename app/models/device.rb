# == Schema Information
#
# Table name: devices
#
#  id           :integer          not null, primary key
#  person_id    :string(255)
#  device_type  :string(255)
#  device_token :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#

class Device < ActiveRecord::Base
  belongs_to :person
end
