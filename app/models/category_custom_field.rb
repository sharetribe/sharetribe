# == Schema Information
#
# Table name: category_custom_fields
#
#  id              :integer          not null, primary key
#  category_id     :integer
#  custom_field_id :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class CategoryCustomField < ActiveRecord::Base
  belongs_to :category
  belongs_to :custom_field

  def self.find_by_category_and_subcategory(category)
    CategoryCustomField.where(:category_id => category.own_and_subcategory_ids)
  end
end
