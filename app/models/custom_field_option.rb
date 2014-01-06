class CustomFieldOption < ActiveRecord::Base
  include Comparable

  belongs_to :custom_field
  attr_accessible :sort_priority

  has_many :titles, :class_name => "CustomFieldOptionTitle"

  def title(locale="en")
    t = titles.find { |title| title.locale == locale.to_s }
    t ? t.value : ""
  end

  def <=> other
    self.sort_priority <=> other.sort_priority
  end
end
