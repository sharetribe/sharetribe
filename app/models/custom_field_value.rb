class CustomFieldValue < ActiveRecord::Base
  belongs_to :listing
  attr_accessible :text_value
end
