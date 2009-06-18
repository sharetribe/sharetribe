class Conversation < ActiveRecord::Base

  after_save :update_read_statuses, :save_person_conversations

  belongs_to :listing

  has_many :person_conversations
  has_many :participants, :through => :person_conversations, :source => :person
  
  has_many :messages
  
  attr_accessor :request_protocol, :request_host
  
  validates_length_of :title, :within => 2..100
  validates_numericality_of :listing_id, :only_integer => true, :allow_nil => true 

  # Includes the title of the conversation in the url
  def to_param
    "#{id}_#{title.to_s.gsub(/\W/, '_').downcase}"
  end
  
  # Creates a new message in the conversation
  def message_attributes=(attributes)
    messages.build(attributes)
  end
  
  # Sets the participants of the conversation
  def conversation_participants=(conversation_participants)
    Person.find(conversation_participants).each do |participant|
      is_read = (participant.id == messages.first.sender.id) ? 1 : 0
      person_conversations.build(:person_id => participant.id,
                                 :is_read => is_read,
                                 :last_sent_at => created_at)
    end
  end 
  
  # Send email notification to message receivers and returns the receivers
  def send_email_to_participants(request)
    if RAILS_ENV == "production"
      recipients(last_message.sender).each do |recipient|
        if recipient.settings.email_when_new_comment == 1
          UserMailer.deliver_notification_of_new_message(recipient, last_message, request)
        end  
      end
    end
  end
  
  # Updates read statuses for each participant so that the sender of the newest
  # message has read the conversation and others haven't
  def update_read_statuses
    person_conversations.each do |p_c|
      if p_c.person_id == last_message.sender.id
        p_c.update_attribute(:last_sent_at, last_message.created_at)
      else
        p_c.update_attributes({ :is_read => 0, :last_received_at => last_message.created_at })
      end  
    end
  end
  
  # Returns all the participants except the message sender
  def recipients(sender)
    participants.reject { |p| p.id == sender.id }
  end
  
  # Returns the last created message
  def last_message  
    messages.last
  end
  
  # Saves the participations to the db.
  def save_person_conversations
    person_conversations.each { |p_c| p_c.save }
  end

end
