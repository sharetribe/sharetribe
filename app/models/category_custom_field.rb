class CategoryCustomField < ActiveRecord::Base
  belongs_to :category
  belongs_to :custom_field
end
