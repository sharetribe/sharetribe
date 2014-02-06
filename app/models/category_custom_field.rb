class CategoryCustomField < ActiveRecord::Base
  belongs_to :category
  belongs_to :custom_field

  def self.find_by_category_and_subcategory(category)
    CategoryCustomField.where(:category_id => category.own_and_subcategory_ids)
  end
end
