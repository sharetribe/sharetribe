# == Schema Information
#
# Table name: bcc_statuses
#
#  id                            :integer          not null, primary key
#  background_check_container_id :integer
#  status                        :text
#  bg_color                      :string(255)
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#
# Indexes
#
#  index_bcc_statuses_on_background_check_container_id  (background_check_container_id)
#

class BccStatus < ActiveRecord::Base
  attr_accessible :background_check_container_id, :bg_color, :status

  belongs_to :background_check_container
end
