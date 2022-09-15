# == Schema Information
#
# Table name: custom_field_options
#
#  id              :integer          not null, primary key
#  custom_field_id :integer
#  sort_priority   :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_custom_field_options_on_custom_field_id  (custom_field_id)
#
class CustomFieldOptionSerializer < ActiveModel::Serializer
   attributes :id
   has_many :titles, foreign_key: :custom_field_option_id, class_name: 'CustomFieldOptionTitle'
   #has_many :titles
end
