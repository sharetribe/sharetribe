class Reservation < Conversation
  
  has_many :item_reservations
  has_many :items, :through => :item_reservations, :source => :item
  
  after_update :save_item_reservations
  
  VALID_STATUS = ["pending_owner", "pending_reserver", "accepted", "rejected"]
  
  validates_inclusion_of :status, :in => VALID_STATUS
  
  validate :pick_up_time_is_earlier_than_return_time
  
  validates_associated :item_reservations
  
  # Makes sure that pick up time is earlier than return time
  def pick_up_time_is_earlier_than_return_time
    if pick_up_time >= return_time
      errors.add(:return_time, "must be after pick up time")
    end  
  end
  
  # Saves the data from reserved items to the database
  def reserved_items=(reserved_items)
    reserved_items.each do |id, amount|
      item_reservations.build(:item_id => id, :amount => amount)
    end
  end
  
  # Updates reserved items
  def existing_reserved_items=(reserved_items)
    logger.info "Item reservations1: " + item_reservations.inspect
    item_reservations.each do |ir|
      amount = reserved_items[ir.item_id.to_s]
      if amount 
        ir.amount = amount
      end
    end 
  end
  
  # Returns the owner of the reserved items
  def item_owner
    items.first.owner
  end
  
  # Returns true if the given person is allowed to edit
  # the current reservation
  def is_allowed_to_edit?(person)
    if person.id == item_owner.id && status.eql?("pending_owner")
      return true
    elsif person.id != item_owner.id && status.eql?("pending_reserver")
      return true
    end
    return false      
  end
  
  # Saves item reservations after update
  def save_item_reservations
    item_reservations.each do |ir| 
      ir.save(false) 
    end 
  end 
  
end  