class Transaction < ActiveRecord::Base
  belongs_to :sender, :class_name => "Person", :foreign_key => "sender_id"
  belongs_to :receiver, :class_name => "Person", :foreign_key => "receiver_id"
  
  validates_presence_of :sender_id, :receiver_id, :amount
  
  validates_numericality_of :amount, :only_integer => true, :greater_than => 0, :allow_nil => true
   
end
