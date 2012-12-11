class Conversation < ActiveRecord::Base

  belongs_to :listing
  
  has_many :messages, :dependent => :destroy 
  
  has_many :participations, :dependent => :destroy
  has_many :participants, :through => :participations, :source => :person
  
  VALID_STATUSES = ["pending", "accepted", "rejected", "free"]
  
  validates_length_of :title, :in => 1..120, :allow_nil => false
  validates_inclusion_of :status, :in => VALID_STATUSES
  
  def self.unread_count(person_id)
    Conversation.scoped.
    joins(:participations).
    joins(:listing).
    where("(participations.is_read = '0' OR (conversations.status = 'pending' AND listings.author_id = '#{person_id}')) AND participations.person_id = '#{person_id}'").
    count
  end
  
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
    (messages[count].present? && messages[count].sender.eql?(user) == received) ? last_message(user, received, (count-1)) : messages[count]
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
  
  def can_be_cancelled?
    participations.each { |p| return false unless p.feedback_can_be_given? }
    return true
  end

  def has_feedback_from?(person)
    participations.find_by_person_id(person.id).has_feedback?
  end
  
  def feedback_skipped_by?(person)
    participations.find_by_person_id(person.id).feedback_skipped?
  end
  
  # Send email notification to message receivers and returns the receivers
  def send_email_to_participants(host)
    recipients(messages.last.sender).each do |recipient|
      if recipient.should_receive?("email_about_new_messages")
        PersonMailer.new_message_notification(messages.last, host).deliver
      end  
    end
  end
  
  # Returns all the participants except the message sender
  def recipients(sender)
    participants.reject { |p| p.id == sender.id }
  end
  
  def change_status(new_status, current_user, current_community, community_domain)
    update_attribute(:status, new_status)
    participations.find_by_person_id(current_user.id).update_attribute(:is_read, true)
    Delayed::Job.enqueue(ConversationAcceptedJob.new(id, current_user.id, current_community.id, community_domain)) 
  end
  
  def has_feedback_from_all_participants?
    participations.each { |p| return false if p.feedback_can_be_given? }
    return true
  end
  
  def offerer
    participants.each { |p| return p if listing.offerer?(p) }
  end
  
  def requester
    participants.each { |p| return p unless listing.offerer?(p) }
  end

end
