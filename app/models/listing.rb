class Listing < ActiveRecord::Base
  
  #belongs_to :author, :class_name => "Person", :foreign_key => "author_id"
  
  #type, category, share_type
  
  VALID_TYPES = ["offer", "request"]
  
  validates_presence_of :author_id
  validates_length_of :title, :in => 1..100, :allow_nil => false
  validates_inclusion_of :listing_type, :in => VALID_TYPES
  
end  