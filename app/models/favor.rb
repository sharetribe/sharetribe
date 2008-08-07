class Favor < ActiveRecord::Base
  belongs_to :person
  validates_presence_of :owner_id, :title
  
  validates_length_of :title, :within => 2..70 
  validates_length_of :description, :allow_nil => true, :allow_blank => true, :maximum => 400 
  validates_length_of :payment, :allow_nil => true, :allow_blank => true, :maximum => 50
  
end
