class Feedback < ActiveRecord::Base

  belongs_to :author, :class_name => "Person"
  
  validates_presence_of :content, :author_id, :url
  
  attr_accessor :title
  
end
