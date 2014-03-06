class CustomFieldValue < ActiveRecord::Base
  attr_accessible :type

  belongs_to :listing
  belongs_to :question, :class_name => "CustomField", :foreign_key => "custom_field_id"

  delegate :with_type, :to => :question

  default_scope includes(:question).order("custom_fields.sort_priority")

end
