class ItemReservation < ActiveRecord::Base
  
  belongs_to :reservation
  belongs_to :item
  
  validates_numericality_of :amount, :greater_than_or_equal_to => 1
  
  validate :amount_is_not_bigger_than_offered
  
  # Makes sure that the item amounts in the reservation
  # are not bigger than the amounts offered by the owner
  def amount_is_not_bigger_than_offered
    item = Item.find(item_id, :select => "title, amount")
    if amount > item.amount 
      errors.add_to_base("You cannot borrow more than #{item.amount.to_s} pieces of item #{item.title.to_s}")
    end
  end
  
end
