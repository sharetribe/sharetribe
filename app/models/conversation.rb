class Conversation < ActiveRecord::Base

  belongs_to :listing
  
  has_many :messages, :dependent => :destroy 
  
  has_many :participations, :dependent => :destroy
  has_many :participants, :through => :participations, :source => :person
  
  VALID_STATUSES = ["pending", "accepted", "rejected"]
  
  validates_length_of :title, :in => 1..100, :allow_nil => false
  validates_inclusion_of :status, :in => VALID_STATUSES
  
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
  
  # Returns last received or sent message
  def last_message(user, received = true, count = -1)
    (messages[count].sender.eql?(user) == received) ? last_message(user, received, (count-1)) : messages[count]
  end
  
  def other_party(person)
    participants.reject { |p| p.id == person.id }.first
  end  

  def read_by?(person)
    participations.where(["person_id LIKE ?", person.id]).first.is_read
  end
  
  # If listing is an offer, return request, otherwise return offer
  def discussion_type
    listing.listing_type.eql?("request") ? "offer" : "request"
  end
  
  def has_feedback?
    participations.each { |p| return true if p.has_feedback? }
    return false
  end

  def has_feedback_from?(person)
    participations.find_by_person_id(person.id).has_feedback?
  end

end
