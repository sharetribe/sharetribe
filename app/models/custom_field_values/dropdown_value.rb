class DropdownValue < OptionFieldValue
  validates_length_of :custom_field_option_selections, :is => 1
end
