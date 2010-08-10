class Message < ActiveRecord::Base

  belongs_to :sender, :class_name => "Person"
  belongs_to :conversation
  
  validates_presence_of :sender_id, :content
  
end
