class CustomFieldName < ActiveRecord::Base
  attr_accessible :locale, :value
  belongs_to :custom_field, touch: true
  validates :locale, :value, presence: true
end
