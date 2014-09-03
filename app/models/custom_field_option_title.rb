# == Schema Information
#
# Table name: custom_field_option_titles
#
#  id                     :integer          not null, primary key
#  value                  :string(255)
#  locale                 :string(255)
#  custom_field_option_id :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

class CustomFieldOptionTitle < ActiveRecord::Base
  attr_accessible :locale, :value
  validates :value, :locale, presence: true

  belongs_to :custom_field_option, touch: true

end
