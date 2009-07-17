class Item < ActiveRecord::Base
  
  belongs_to :owner, :class_name => "Person", :foreign_key => "owner_id"
  
  has_many :kassi_events, :as => :eventable
  
  has_and_belongs_to_many :groups
  
  has_many :item_reservations
  has_many :reservations, :through => :item_reservations, :source => :reservation
  
  acts_as_ferret :fields => {
    :title => {},
    :description => {}, 
    :title_sort => {
      :index => :untokenized
    }
  }
  
  VALID_STATUSES = ["enabled", "disabled"]
  
  # Possible visibility types
  POSSIBLE_VISIBILITIES = ["everybody", "kassi_users", "friends", "contacts", "groups", "f_c", "f_g", "c_g", "f_c_g", "none"]
  
  validates_presence_of :title, :message => "is required"
  validates_presence_of :owner_id
  validates_length_of :title, :within => 2..70
  validates_length_of :description, :allow_nil => true, :allow_blank => true, :maximum => 400, :message => "is too long"    
  validates_numericality_of :payment, :only_integer => true, :greater_than_or_equal_to => 0, :allow_nil => true, :allow_blank => true
  validates_numericality_of :amount, :greater_than_or_equal_to => 1
  validates_inclusion_of :status, :in => VALID_STATUSES
  validates_inclusion_of :visibility, :in => POSSIBLE_VISIBILITIES
  
  validate :owner_does_not_have_item_with_same_title
  
  def owner_does_not_have_item_with_same_title
    if self.owner_id
      items = Item.find(:all, :conditions => ["owner_id = ?", self.owner.id])
      items.each do |item|
        if item.title && self.title && item.title.downcase.eql?(self.title.downcase)
          unless self.id && self.id == item.id 
            errors.add(:title, "item_with_proposed_title_already_exists")
          end  
        end
      end 
    end 
  end
  
  def title_sort
    title
  end
  
  def disable
    update_attribute :status, "disabled"
  end
  
  def enable
    update_attribute :status, "enabled"
  end
  
  # Save group visibility data to db
  def save_group_visibilities(group_ids)
    groups.clear
    if group_ids
      selected_groups = Group.find(group_ids)
      selected_groups.each do |group|
        groups << group
      end
    end
  end
  
  # Returns the amount of items that are free on the given time period
  def get_availability(pick_up_time, return_time, reservation_id=nil)
    
    # Get all item reservations of this item that occur on the given time frame
    # and are not rejected.
    # If editing a reservation, that reservation is excluded with reservation_condition.
    # If no such reservations can be found, return the total item amount.
    reservation_condition = reservation_id ? "AND c.id <> '#{reservation_id}'" : ""
    time_conditions = "((c.pick_up_time > '#{pick_up_time}' AND c.pick_up_time < '#{return_time}')
                      OR (c.pick_up_time < '#{pick_up_time}' AND c.return_time > '#{return_time}')
                      OR (c.return_time > '#{pick_up_time}' AND c.return_time < '#{return_time}'))"
    reservation_query = "
      SELECT DISTINCT ir.id, ir.amount, ir.item_id, ir.reservation_id
      FROM conversations AS c, item_reservations AS ir
      WHERE c.id = ir.reservation_id
      AND c.status <> 'Rejected'
      AND ir.item_id = '#{id.to_s}'
      AND #{time_conditions}
      #{reservation_condition}
      "
    item_reservations = ItemReservation.find_by_sql(reservation_query)
    return amount unless item_reservations.size > 0
    
    # If overlapping reservations are found, we need to divide the given timeframe into intervals.
    # By these we mean the pick up times and return times of found reservations that occur on the
    # given timeframe. We put all these dates in an array and order it. The first item of the array
    # is the pick up time of the given time frame and the last item is the return time of the given
    # time frame.
    intervals = []
    ranges = []   
    intervals << pick_up_time << return_time
    intervals = item_reservations.inject(intervals) { 
      |array, ir| array << ir.reservation.pick_up_time << ir.reservation.return_time 
    }.reject { 
      |t| (t < pick_up_time) || (t > return_time) 
    }.uniq.sort { 
      |a,b| a <=> b 
    }
    
    # Get date ranges between all dates in the interval array and put them in a new array.
    for i in 0..(intervals.size - 2) do
      range = intervals[i]..intervals[i+1]
      ranges << range
    end
    
    # For each range, check if any found reservation occurs in it, and if true,
    # add the amount of that ir to the reserved item amount of that range. Finally, return the
    # amount of the range with most reserved items.
    biggest_reservation_amount = ranges.inject(0) do |amount, range|
      range_amount = 0
      item_reservations.each do |ir|
        if (range.include?(ir.reservation.pick_up_time) || range.include?(ir.reservation.return_time) || 
          (range.first > ir.reservation.pick_up_time && range.last < ir.reservation.return_time))
          range_amount += ir.amount 
        end  
      end
      amount >= range_amount ? amount : range_amount  
    end      
    
    # Return total amount - amount of the range with most reserved items,
    # e.g. the amount of free items on given time frame.
    amount - biggest_reservation_amount    
  end
  
end
