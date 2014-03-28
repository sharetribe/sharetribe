class NewsItem < ActiveRecord::Base

  belongs_to :community
  belongs_to :author, :class_name => "Person"

  validates_length_of :content, :minimum => 1, :maximum => 10000, :allow_nil => false
  validates_length_of :title, :minimum => 1, :maximum => 200, :allow_nil => false

end
