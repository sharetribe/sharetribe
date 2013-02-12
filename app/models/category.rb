class Category < ActiveRecord::Base
  has_many :subcategories, :class_name => "Category", :foreign_key => "parent_id"
  belongs_to :parent, :class_name => "Category"
  has_many :communities, :through => :community_categories
  
  validates_presence_of :name
  validates_uniqueness_of :name
  
end
