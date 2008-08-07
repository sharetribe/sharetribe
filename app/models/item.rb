class Item < ActiveRecord::Base
  belongs_to :person
  validates_presence_of :title, :owner_id
  
  validates_length_of :title, :within => 2..50   
  
end
