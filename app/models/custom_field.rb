class CustomField < ActiveRecord::Base
  include SortableByPriority # use `sort_priority()` for sorting
  
  attr_accessible :type, :name_attributes, :category_attributes, :option_attributes, :sort_priority
  
  has_many :names, :class_name => "CustomFieldName", :dependent => :destroy

  has_many :category_custom_fields, :dependent => :destroy
  has_many :categories, :through => :category_custom_fields

  has_many :answers, :class_name => "CustomFieldValue", :dependent => :destroy
  
  VALID_TYPES = [["Dropdown", "DropdownField"]]

  validates_length_of :names, :minimum => 1
  validates_length_of :categories, :minimum => 1
  
  def name_attributes=(attributes)
    attributes.each { |name| names.build(name) }
  end
  
  def category_attributes=(attributes)
    attributes.each { |category_id, category_present| category_custom_fields.build(:category_id => category_id) }
  end
  
  def option_attributes=(attributes)
    logger.info "Attributes: #{attributes.inspect}"
    attributes.each { |index, option| options.build(option) }
  end

  def name(locale="en")
    n = names.find { |name| name.locale == locale.to_s }
    n ? n.value : ""
  end

  def answer_for(listing)
    CustomFieldValue.find_by_listing_id_and_custom_field_id(listing.id, self.id)
  end
end
