class Conversation < ActiveRecord::Base

  belongs_to :listing
  
  has_many :messages, :dependent => :destroy 
  
  has_many :participations, :dependent => :destroy
  has_many :participants, :through => :participations, :source => :person
  
  validates_length_of :title, :in => 1..100, :allow_nil => false
  
  # Creates a new message to the conversation
  def message_attributes=(attributes)
    messages.build(attributes)
  end
  
  # Sets the participants of the conversation
  def conversation_participants=(conversation_participants)
    conversation_participants.each do |participant, is_sender|
      last_at = is_sender.eql?("true") ? "last_sent_at" : "last_received_at"
      participations.build(:person_id => participant,
                           :is_read => is_sender,
                           last_at.to_sym => DateTime.now)
    end
  end
  
  def last_message(user, received = true, count = -1)
    if messages[count].sender.eql?(user) == received
      count -= 1
      last_received_message(user, received, count)
    else
      messages[count]
    end
  end
  
  def other_party(person)
    participants.reject { |p| p.id == person.id }.first
  end  

  def read?(person)
    participations.where(["person_id LIKE ?", person.id]).first.is_read
  end

end
