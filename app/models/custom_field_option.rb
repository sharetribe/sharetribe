class CustomFieldOption < ActiveRecord::Base
  belongs_to :custom_field
  attr_accessible :sort_priority

  has_many :titles, :class_name => "CustomFieldOptionTitle"

  def title(locale="en")
    t = titles.find { |title| title.locale == locale.to_s }
    t ? t.value : ""
  end
end
