class SelectedOption < ActiveRecord::Base
  belongs_to :custom_field_value
  belongs_to :custom_field_option
end
