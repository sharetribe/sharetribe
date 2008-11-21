class Favor < ActiveRecord::Base
  belongs_to :person
  has_many :kassi_events, :as => :eventable
  
  validates_presence_of :owner_id, :title
  
  validates_length_of :title, :within => 2..70 
  validates_length_of :description, :allow_nil => true, :allow_blank => true, :maximum => 400 
  validates_numericality_of :payment, :only_integer => true, :greater_than_or_equal_to => 0, :allow_nil => true, :allow_blank => true
  
end
