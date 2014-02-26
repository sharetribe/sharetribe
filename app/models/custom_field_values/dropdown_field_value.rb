class DropdownFieldValue < CustomFieldValue

  has_many :custom_field_option_selections, :dependent => :destroy
  has_many :selected_options, :through => :custom_field_option_selections, :source => :custom_field_option

  validates_length_of :selected_options, :is => 1

end