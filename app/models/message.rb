class Message < ActiveRecord::Base

  after_save :update_conversation_read_status

  belongs_to :sender, :class_name => "Person"
  belongs_to :conversation
  
  validates_presence_of :sender_id, :content
  
  def update_conversation_read_status
    conversation.participations.each do |p|
      last_at = p.person.eql?(sender) ? :last_sent_at : :last_received_at
      p.update_attributes({ :is_read => p.person.eql?(sender), last_at => created_at})
    end  
  end
  
end
