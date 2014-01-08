class CustomFieldValue < ActiveRecord::Base
  include SortableByPriority # use `sort_priority()` for sorting
  
  belongs_to :listing
  belongs_to :question, :class_name => "CustomField", :foreign_key => "custom_field_id"
  attr_accessible :text_value

  has_many :selected_options, :dependent => :destroy
  has_many :options, :through => :selected_options, :source => :custom_field_option

  delegate :sort_priority, :with_type, :to => :question
end
