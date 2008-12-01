class Message < ActiveRecord::Base

  belongs_to :sender, :class_name => "Person"
  belongs_to :conversation
  
  attr_accessor :receiver_id, :listing_id, :title, :current_conversation, :item_id, :favor_id
  
  validates_presence_of :sender_id, :content
  
  validates_numericality_of :conversation_id, :only_integer => true, :allow_nil => true
  
end
