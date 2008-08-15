class Message < ActiveRecord::Base
  belongs_to :receiver, :class_name => "Person", :foreign_key => "receiver_id"
  # Refer to the second person as "sender".
  belongs_to :sender, :class_name => "Person", :foreign_key => "sender_id"
  belongs_to :listing
  
  validates_presence_of :sender_id, :receiver_id
  
  validates_numericality_of :listing_id, :only_integer => true, :allow_nil => true
end
