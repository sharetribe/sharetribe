class Category < ActiveRecord::Base
  has_many :subcategories, :class_name => "Category", :foreign_key => "parent_id"
  # children is a more generic alias for sub categories, used in classification.rb
  has_many :children, :class_name => "Category", :foreign_key => "parent_id"
  belongs_to :parent, :class_name => "Category"
  has_many :communities, :through => :community_categories
  has_many :listings
  has_many :translations, :class_name => "CategoryTranslation"
  
  validates_presence_of :name
  validates_uniqueness_of :name
  
  # Classification module contains methods that are common to Category and ShareType
  include Classification

end
