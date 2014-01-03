class CustomFieldValue < ActiveRecord::Base
  belongs_to :listing
  belongs_to :question, :class_name => "CustomField", :foreign_key => "custom_field_id"
  attr_accessible :text_value

  has_many :selected_options

  delegate :with_type, :to => :question
end
