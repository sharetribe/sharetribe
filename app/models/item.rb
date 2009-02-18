class Item < ActiveRecord::Base
  
  belongs_to :owner, :class_name => "Person", :foreign_key => "owner_id"
  
  has_many :kassi_events, :as => :eventable
  
  acts_as_ferret :fields => {
    :title => {},
    :title_sort => {
      :index => :untokenized
    }
  }
  
  VALID_STATUSES = ["enabled", "disabled"]
  
  validates_presence_of :title, :owner_id
  validates_length_of :title, :within => 2..50    
  validates_numericality_of :payment, :only_integer => true, :greater_than_or_equal_to => 0, :allow_nil => true, :allow_blank => true
  validates_inclusion_of :status, :in => VALID_STATUSES
  
  validate :owner_does_not_have_item_with_same_title
  
  def owner_does_not_have_item_with_same_title
    if self.owner_id
      items = Item.find(:all, :conditions => ["owner_id = ?", self.owner.id])
      items.each do |item|
        if item.title && self.title && item.title.downcase.eql?(self.title.downcase)
          errors.add(:title, "item_with_proposed_title_already_exists")
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
  
end
