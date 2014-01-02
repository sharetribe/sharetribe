class CustomFieldOption < ActiveRecord::Base
  belongs_to :CustomField
  attr_accessible :sort_priority
end
