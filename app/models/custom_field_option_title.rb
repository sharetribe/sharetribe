class CustomFieldOptionTitle < ActiveRecord::Base
  attr_accessible :locale, :value
  validates :value, :locale, presence: true

  belongs_to :custom_field_option, touch: true

end
