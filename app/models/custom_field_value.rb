class CustomFieldValue < ActiveRecord::Base
  include Comparable
  
  belongs_to :listing
  belongs_to :question, :class_name => "CustomField", :foreign_key => "custom_field_id"
  attr_accessible :text_value

  has_many :selected_options

  delegate :with_type, :to => :question

  def <=> other
    # Answer follows question's sort priority
    question.sort_priority <=> other.question.sort_priority
  end
end
