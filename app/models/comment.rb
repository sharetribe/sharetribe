class Comment < ActiveRecord::Base
  belongs_to :author, :class_name => "Person", :foreign_key => "author_id"
  belongs_to :listing
  
  validates_presence_of :author_id
  validates_numericality_of :listing_id, :only_integer => true, :allow_nil => true
end
