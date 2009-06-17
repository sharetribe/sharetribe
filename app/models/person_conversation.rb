class PersonConversation < ActiveRecord::Base
  
  belongs_to :conversation
  belongs_to :person

  # Get receivers of a message and update everybody's read status for this conversation 
  def self.get_receivers(current_user, message)
    find_by_conversation_id(message.conversation_id).collect { |p_c| p_c.update_read_status(current_user, message) }.compact
  end
  
  # Updates read status of a person conversation and returns
  # the person unless the person is the current user
  def update_read_status(current_user, message, receivers)
    if person.id == current_user.id
      update_attribute(:last_sent_at, message.created_at)
      return nil
    else  
      person_conversation.update_attributes({ :is_read => 0, :last_received_at => @message.created_at })
      return person
    end
  end  

end
