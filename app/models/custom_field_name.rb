# == Schema Information
#
# Table name: custom_field_names
#
#  id              :integer          not null, primary key
#  value           :string(255)
#  locale          :string(255)
#  custom_field_id :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_custom_field_names_on_custom_field_id  (custom_field_id)
#  locale_index                                 (custom_field_id,locale)
#

class CustomFieldName < ActiveRecord::Base
  attr_accessible :locale, :value
  belongs_to :custom_field, touch: true
  validates :locale, :value, presence: true
end
