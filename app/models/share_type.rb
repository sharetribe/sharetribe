class ShareType < ActiveRecord::Base
  
  # Classification module contains methods that are common to Category and ShareType
  include Classification
  
  
  
  has_many :sub_share_types, :class_name => "ShareType", :foreign_key => "parent_id"
  # children is a more generic alias for sub share_types, used in classification.rb
  has_many :children, :class_name => "ShareType", :foreign_key => "parent_id"
  belongs_to :parent, :class_name => "ShareType"
  has_many :community_categories, :dependent => :destroy 
  has_many :communities, :through => :community_categories
  has_many :listings
  has_many :translations, :class_name => "ShareTypeTranslation", :dependent => :destroy 

  validates_presence_of :name
  validate :name_is_not_taken_by_categories_or_share_types
  
  def is_offer?
    top_level_parent.transaction_type.eql?("offer")
  end
  
  def is_request?
    top_level_parent.transaction_type.eql?("request")
  end
  
end
