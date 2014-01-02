class CustomFieldOption < ActiveRecord::Base
  belongs_to :custom_field
  attr_accessible :sort_priority
end
