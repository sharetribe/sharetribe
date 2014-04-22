class Conversation < ActiveRecord::Base

  belongs_to :listing

  has_many :messages, :dependent => :destroy

  has_many :participations, :dependent => :destroy
  has_many :participants, :through => :participations, :source => :person
  belongs_to :community

  has_many :transaction_transitions

  has_one :payment

  VALID_STATUSES = ["pending", "accepted", "rejected", "paid", "free", "confirmed", "canceled"]

  validates_length_of :title, :in => 1..120, :allow_nil => false

  # Delegate methods to state machine
  delegate :can_transition_to?, :transition_to!, :transition_to, :current_state,
           to: :state_machine

  def state_machine
    @state_machine ||= TransactionProcess.new(self, transition_class: TransactionTransition)
  end

  def status=(new_status)
    transition_to! new_status.to_sym
  end

  def status
    current_state
  end

  def self.unread_count(person_id)
    user = Person.find_by_id(person_id)
    new_value = user.participations.select do |particiation|
      author_not_responded = particiation.conversation.status == "pending" && particiation.conversation.listing.author == user

      !particiation.is_read || author_not_responded
    end.count
  end

  # Creates a new message to the conversation
  def message_attributes=(attributes)
    messages.build(attributes)
  end

  def payment_attributes=(attributes)
    payment ||= community.payment_gateway.new_payment
    payment.conversation = self
    payment.status = "pending"
    payment.payer = requester
    payment.recipient = offerer
    payment.community_id = attributes[:community_id]
    # Simple payment form
    if attributes[:sum]
      payment.sum_cents = Money.parse(attributes[:sum]).cents
      payment.currency = attributes[:currency]
    # Complex (multi-row) payment form
    else
      attributes[:payment_rows].each { |row| payment.rows.build(row.merge(:currency => "EUR")) unless row["title"].blank? }
    end

    payment.save!
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
  def last_message(user=nil, received = true, count = -1)
    if user.nil? # no matter which way, just return the last one
      return messages.last
    else
      (messages[count].present? && messages[count].sender.eql?(user) == received) ? last_message(user, received, (count-1)) : messages[count]
    end
  end

  def other_party(person)
    participants.reject { |p| p.id == person.id }.first
  end

  def read_by?(person)
    participations.where(["person_id LIKE ?", person.id]).first.is_read
  end

  # If listing is an offer, return request, otherwise return offer
  def discussion_type
    listing.transaction_type.is_request? ? "offer" : "request"
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
  def send_email_to_participants(community)
    recipients(messages.last.sender).each do |recipient|
      if recipient.should_receive?("email_about_new_messages")
        PersonMailer.new_message_notification(messages.last, community).deliver
      end
    end
  end

  # Returns all the participants except the message sender
  def recipients(sender)
    participants.reject { |p| p.id == sender.id }
  end

  def update_is_read(current_user)
    # TODO
    # What does this actually do? What happens if requester.eql? current_user?
    if offerer.eql?(current_user)
      participations.each { |p| p.update_attribute(:is_read, p.person.id.eql?(current_user.id)) }
    end
  end

  def has_feedback_from_all_participants?
    participations.each { |p| return false if p.feedback_can_be_given? }
    return true
  end

  def offerer
    participants.each { |p| return p if listing.offerer?(p) }
  end

  def requester
    participants.each { |p| return p if listing.requester?(p) }
  end

  # If payment through Sharetribe is required to
  # complete the transaction, return true, whether the payment
  # has been conducted yet or not.
  def requires_payment?(community)
    listing && community.payment_possible_for?(listing)
  end

  # Return true if the next required action is the payment
  def waiting_payment?(community)
    requires_payment?(community) && status.eql?("accepted")
  end

  # Return true if the transaction is in a state that it can be confirmed
  def can_be_confirmed?
    can_transition_to?(:confirmed)
  end

  # Return true if the transaction is in a state that it can be canceled
  def can_be_canceled?
    can_transition_to?(:canceled)
  end

end
