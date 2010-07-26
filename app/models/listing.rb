class Listing < ActiveRecord::Base
  
  #belongs_to :author, :class_name => "Person", :foreign_key => "author_id"
  
  #type, category, share_type
  
  VALID_TYPES = ["offer", "request"]
  VALID_CATEGORIES = ["item", "favor", "rideshare", "housing"]
  
  validates_presence_of :author_id
  validates_length_of :title, :in => 1..100, :allow_nil => false
  validates_length_of :description, :maximum => 5000, :allow_nil => true
  validates_inclusion_of :listing_type, :in => VALID_TYPES
  validates_inclusion_of :category, :in => VALID_CATEGORIES
  
  # Overrides the to_param method to implement clean URLs
  def to_param
    "#{id}-#{title.gsub(/\W/, '_').downcase}"
  end
  
end  