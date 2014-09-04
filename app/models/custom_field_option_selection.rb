# == Schema Information
#
# Table name: custom_field_option_selections
#
#  id                     :integer          not null, primary key
#  custom_field_value_id  :integer
#  custom_field_option_id :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_selected_options_on_custom_field_value_id  (custom_field_value_id)
#

class CustomFieldOptionSelection < ActiveRecord::Base
  # WARNING! This expects that there's only one selection (Dropdown).
  # If there are multiple selections, the custom_field_value should not be deleted
  # if one of the selected options are deleted
  belongs_to :custom_field_value, dependent: :destroy
  belongs_to :custom_field_option
end
