# == Schema Information
#
# Table name: custom_field_options
#
#  id              :integer          not null, primary key
#  custom_field_id :integer
#  sort_priority   :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_custom_field_options_on_custom_field_id  (custom_field_id)
#

class CustomFieldOption < ActiveRecord::Base
  include SortableByPriority # use `sort_priority()` for sorting

  belongs_to :custom_field
  attr_accessible :sort_priority, :title_attributes

  has_many :titles, :foreign_key => "custom_field_option_id", :class_name => "CustomFieldOptionTitle", :dependent => :destroy

  has_many :custom_field_option_selections, :dependent => :destroy
  has_many :custom_field_values, :through => :custom_field_option_selections

  validates_length_of :titles, :minimum => 1

  def title(locale="en")
    TranslationCache.new(self, :titles).translate(locale, :value)
  end

  def title_attributes=(attributes)
    attributes.each do |locale, value|
      if title = titles.find_by_locale(locale)
        title.update_attribute(:value, value)
      else
        titles.build(:value => value, :locale => locale)
      end
    end
  end
end
