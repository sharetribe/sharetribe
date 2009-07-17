class ItemReservation < ActiveRecord::Base
  
  belongs_to :reservation
  belongs_to :item
  
  validates_numericality_of :amount, :greater_than_or_equal_to => 1
    
end
