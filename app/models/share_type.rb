class ShareType < ActiveRecord::Base
  has_many :sub_share_types, :class_name => "ShareType", :foreign_key => "parent_id"
  belongs_to :parent, :class_name => "ShareType"
  has_many :communities, :through => :community_categories
  has_many :listings
  has_many :translations, :class_name => "ShareTypeTranslation"
  
  validates_presence_of :name
  validates_uniqueness_of :name
  
  
  # Classification module contains methods that are common to Category and ShareType
  include Classification
  
end
