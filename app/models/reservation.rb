class Reservation < Conversation
  
  has_many :item_reservations
  has_many :items, :through => :item_reservations, :source => :item
  
  has_one :kassi_event, :as => :eventable
  
  after_update :save_item_reservations
  
  VALID_STATUS = ["pending_owner", "pending_reserver", "accepted", "rejected"]
  
  validates_inclusion_of :status, :in => VALID_STATUS
  
  validate :pick_up_time_is_earlier_than_return_time, :no_other_reservations_on_this_time_period
  
  validates_associated :item_reservations
  
  # Makes sure that pick up time is earlier than return time
  def pick_up_time_is_earlier_than_return_time
    if pick_up_time >= return_time
      errors.add(:return_time, errors.generate_message(:return_time, :too_early))
    end  
  end
  
  # Makes sure that there is enough items to borrow
  def no_other_reservations_on_this_time_period
    item_reservations.each do |ir|
      item = ir.item
      amount_available = item.get_availability(pick_up_time.to_datetime, return_time.to_datetime, id)
      if ir.amount > amount_available
        if amount_available > 0
          errors.add(:items, errors.generate_message(:items, :too_few_available, { :item_title => item.title, :count => amount_available.to_s }))
        else
          errors.add(:items, errors.generate_message(:items, :none_available, { :item_title => item.title }))
        end    
      end
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
  
  # Returns the person who has made the reservation.
  def item_requester
    participants.reject { |p| p.id == item_owner.id }.first
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