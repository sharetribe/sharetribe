class CustomFieldValue < ActiveRecord::Base
  include SortableByPriority # use `sort_priority()` for sorting
  
  belongs_to :listing
  belongs_to :question, :class_name => "CustomField", :foreign_key => "custom_field_id"

  delegate :sort_priority, :with_type, :to => :question

end
