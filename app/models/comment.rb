class Comment < ActiveRecord::Base
  
  belongs_to :author, :class_name => "Person"
  belongs_to :listing
  
  validates_length_of :content, :minimum => 1, :maximum => 5000, :allow_nil => false
  
end
