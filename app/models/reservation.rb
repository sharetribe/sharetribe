class Reservation < Conversation
  
  has_many :item_reservations
  has_many :items, :through => :item_reservations, :source => :item
  
  after_update :save_item_reservations
  
  VALID_STATUS = ["pending_owner", "pending_reserver", "accepted", "rejected"]
  
  validates_inclusion_of :status, :in => VALID_STATUS
  
  validate :pick_up_time_is_earlier_than_return_time, :no_other_reservations_on_this_time_period
  
  validates_associated :item_reservations
  
  # Makes sure that pick up time is earlier than return time
  def pick_up_time_is_earlier_than_return_time
    if pick_up_time >= return_time
      errors.add(:return_time, "must be after pick up time")
    end  
  end
  
  # Makes sure that there is enough items to borrow
  def no_other_reservations_on_this_time_period
    item_reservations.each do |ir|
      item = ir.item
      amount_available = item.get_availability(pick_up_time, return_time, id)
      if ir.amount > amount_available
        if amount_available > 0
          errors.add_to_base("Only #{amount_available.to_s} pieces of item #{item.title} available on given time period")
        else
          errors.add_to_base("No pieces of item #{item.title} available on given time period")
        end    
      end
    end    
  end
  
  # Makes sure that there is enough items to borrow
  # for the requested time period.
  # def no_other_reservations_on_this_time_period
  #   # logger.info "Query: " + query  
  #   # logger.info "Reservations: " + reservations.inspect
  #   # logger.info "Reservations size " + reservations.size.to_s
  #   # logger.info "Intervals: " + intervals.inspect
  #   # logger.info "Range: " + range.to_s
  #   
  #   item_ids = item_reservations.collect { |ir| "'#{ir.item_id.to_s}'" }.join(",")
  #   temp_items = item_reservations.collect { |ir| ir.item }
  #   time_conditions = "((c.pick_up_time > '#{pick_up_time}' AND c.pick_up_time < '#{return_time}')
  #                     OR (c.pick_up_time < '#{pick_up_time}' AND c.return_time > '#{return_time}')
  #                     OR (c.return_time > '#{pick_up_time}' AND c.return_time < '#{return_time}'))"
  #   reservation_query = "
  #     SELECT DISTINCT c.id, c.pick_up_time, c.return_time 
  #     FROM conversations AS c, item_reservations AS ir
  #     WHERE c.id = ir.reservation_id
  #     AND ir.item_id IN (#{item_ids})
  #     AND #{time_conditions}
  #     "
  #   reservations = Reservation.find_by_sql(reservation_query)
  #   intervals = []    
  #   intervals << pick_up_time << return_time
  #   intervals = reservations.inject(intervals) { |array, r| array << r.pick_up_time << r.return_time }.reject { |t| (t < pick_up_time) || (t > return_time) }.uniq.sort { |a,b| a <=> b }
  #   amounts = {}
  #   ranges = []
  #   for i in 0..(intervals.size - 2) do
  #     range = intervals[i]..intervals[i+1]
  #     ranges << range
  #     reservations.each do |reservation|
  #       if range.include?(reservation.pick_up_time) || range.include?(reservation.return_time)
  #         reservation.item_reservations.each do |ir|
  #           if temp_items.include?(ir.item)
  #             if amounts[ir.item.id] && amounts[ir.item.id][range.to_s]
  #               amounts[ir.item.id][range.to_s] += ir.amount
  #             else
  #               amounts[ir.item.id] = {}
  #               amounts[ir.item.id][range.to_s] = ir.amount
  #             end
  #           end  
  #         end 
  #       end    
  #     end
  #   end
  #   logger.info "Intervals: " + intervals.inspect
  #   logger.info "Amounts: " + amounts.inspect
  #   logger.info "Temp items: " + temp_items.inspect
  #   logger.info "Ranges: " + ranges.inspect
  #   temp_items.each do |item|
  #     logger.info amounts[item.id]
  #     ranges.each do |range|
  #       if amounts[item.id] && amounts[item.id][range.to_s]
  #         logger.info "On interval " + range.to_s + " " + (amounts[item.id][range.to_s].to_s || "0") + " items out of " + item.amount.to_s + " are reserved."
  #         if amounts[item.id][range.to_s] > item.amount
  #           logger.info amounts[item.id][range.to_s].to_s + " is bigger than " + item.amount.to_s 
  #         else
  #           logger.info amounts[item.id][range.to_s].to_s + " is smaller than " + item.amount.to_s 
  #         end    
  #       end 
  #     end
  #   end  
  # end
  
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