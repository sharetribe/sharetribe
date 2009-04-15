class Favor < ActiveRecord::Base
  belongs_to :owner, :class_name => "Person", :foreign_key => "owner_id"
  
  has_many :kassi_events, :as => :eventable
  
  has_and_belongs_to_many :groups, :join_table => "groups_favors"
  
  acts_as_ferret :fields => {
    :title => {},
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
  validates_inclusion_of :status, :in => VALID_STATUSES
  validates_inclusion_of :visibility, :in => POSSIBLE_VISIBILITIES
  
  validate :owner_does_not_have_favor_with_same_title
  
  def owner_does_not_have_favor_with_same_title
    if self.owner_id
      favors = Favor.find(:all, :conditions => ["owner_id = ?", self.owner.id])
      favors.each do |favor|
        if favor.title && self.title && favor.title.downcase.eql?(self.title.downcase)
          unless self.id && self.id == favor.id 
            errors.add(:title, "favor_with_proposed_title_already_exists")
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
    if group_ids
      groups.clear
      selected_groups = Group.find(group_ids)
      selected_groups.each do |group|
        groups << group
      end
    end
  end
    
end
