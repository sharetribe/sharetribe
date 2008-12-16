class Favor < ActiveRecord::Base
  belongs_to :owner, :class_name => "Person", :foreign_key => "owner_id"
  
  has_many :kassi_events, :as => :eventable
  
  acts_as_ferret :fields => {
    :title => {},
    :title_sort => {
      :index => :untokenized
    }
  }
  
  validates_presence_of :owner_id, :title
  
  validates_length_of :title, :within => 2..70 
  validates_length_of :description, :allow_nil => true, :allow_blank => true, :maximum => 400 
  validates_numericality_of :payment, :only_integer => true, :greater_than_or_equal_to => 0, :allow_nil => true, :allow_blank => true
  
  def title_sort
    title
  end
  
  def disable
    update_attribute :status, "disabled"
  end
  
end
