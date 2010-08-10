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
      participations.build(:person_id => participant,
                           :is_read => is_sender,
                           :last_sent_at => DateTime.now)
    end
  end

end
