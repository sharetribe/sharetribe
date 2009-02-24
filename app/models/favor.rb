class Favor < ActiveRecord::Base
  belongs_to :owner, :class_name => "Person", :foreign_key => "owner_id"
  
  has_many :kassi_events, :as => :eventable
  
  acts_as_ferret :fields => {
    :title => {},
    :title_sort => {
      :index => :untokenized
    }
  }
  
  validates_presence_of :title, :message => "is required"
  validates_presence_of :owner_id
  
  validates_length_of :title, :within => 2..70 
  validates_length_of :description, :allow_nil => true, :allow_blank => true, :maximum => 400, :message => "is too long"  
  validates_numericality_of :payment, :only_integer => true, :greater_than_or_equal_to => 0, :allow_nil => true, :allow_blank => true
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
  
  
end
