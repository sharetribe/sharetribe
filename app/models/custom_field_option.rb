class CustomFieldOption < ActiveRecord::Base
  include SortableByPriority # use `sort_priority()` for sorting

  belongs_to :custom_field
  attr_accessible :sort_priority

  has_many :titles, :class_name => "CustomFieldOptionTitle", :dependent => :destroy

  def title(locale="en")
    t = titles.find { |title| title.locale == locale.to_s }
    t ? t.value : ""
  end
end
