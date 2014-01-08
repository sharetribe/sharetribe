class CustomFieldName < ActiveRecord::Base
  attr_accessible :locale, :value
  validates :locale, :value, presence: true
end
