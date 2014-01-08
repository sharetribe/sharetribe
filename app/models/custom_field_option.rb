class CustomFieldOption < ActiveRecord::Base
  include SortableByPriority # use `sort_priority()` for sorting

  belongs_to :custom_field
  attr_accessible :sort_priority, :title_attributes

  has_many :titles, :class_name => "CustomFieldOptionTitle", :dependent => :destroy


  has_many :selected_options, :dependent => :destroy
  has_many :custom_field_values, :through => :selected_options


  def title(locale="en")
    t = titles.find { |title| title.locale == locale.to_s }
    t ? t.value : ""
  end
  
  def title_attributes=(attributes)
    attributes.each { |title| titles.build(:value => title[:value], :locale => title[:locale]) }
  end
  
end
