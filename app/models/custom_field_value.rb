class CustomFieldValue < ActiveRecord::Base
  include SortableByPriority # use `sort_priority()` for sorting
  
  belongs_to :listing
  belongs_to :question, :class_name => "CustomField", :foreign_key => "custom_field_id"
  attr_accessible :text_value

  has_many :custom_field_option_selections, :dependent => :destroy
  has_many :selected_options, :through => :custom_field_option_selections, :source => :custom_field_option

  validate :text_value_or_selected_option_present

  delegate :sort_priority, :with_type, :to => :question

  def text_value_or_selected_option_present
    errors.add(:base, "CustomFieldValue must have value") unless custom_field_option_selections.size == 1 || text_value
  end

end
