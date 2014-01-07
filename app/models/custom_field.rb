class CustomField < ActiveRecord::Base
  include SortableByPriority # use `sort_priority()` for sorting
  
  attr_accessible :type, :name_attributes, :sort_priority
  
  has_many :names, :class_name => "CustomFieldName"
  has_many :options, :class_name => "CustomFieldOption"

  has_many :category_custom_fields, :dependent => :destroy 
  has_many :categories, :through => :category_custom_fields
  
  VALID_TYPES = [["Dropdown", "DropdownField"]]
  
  def name_attributes=(attributes)
    attributes.each { |a| names.build(a) }
  end

  def name(locale="en")
    n = names.find { |name| name.locale == locale.to_s }
    n ? n.value : ""
  end

  def answer_for(listing)
    CustomFieldValue.find_by_listing_id_and_custom_field_id(listing.id, self.id)
  end
end
