class ListingComment < ActiveRecord::Base
  
  belongs_to :author, :class_name => "Person"
  belongs_to :listing
  
  validates_presence_of :author_id, :listing_id, :content
  validates_numericality_of :listing_id, :only_integer => true
  
end
