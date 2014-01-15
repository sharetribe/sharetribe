class CustomFieldName < ActiveRecord::Base
  attr_accessible :locale, :value
  belongs_to :custom_field
  validates :locale, :value, presence: true
end
