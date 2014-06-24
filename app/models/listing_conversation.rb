class ListingConversation < Conversation
  belongs_to :listing
  has_many :transaction_transitions, dependent: :destroy, foreign_key: :conversation_id
  has_one :payment, foreign_key: :conversation_id


  # Delegate methods to state machine
  delegate :can_transition_to?, :transition_to!, :transition_to, :current_state,
           to: :state_machine

  delegate :author, to: :listing
  delegate :title, to: :listing, prefix: true

  def state_machine
    @state_machine ||= TransactionProcess.new(self, transition_class: TransactionTransition)
  end

  def status=(new_status)
    transition_to! new_status.to_sym
  end

  def status
    current_state
  end

  def payment_attributes=(attributes)
    initialize_payment!

    if attributes[:sum]
      # Simple payment form
      initialize_braintree_payment!(attributes[:sum], attributes[:currency])
    else
      # Complex (multi-row) payment form
      initialize_checkout_payment!(attributes[:payment_rows])
    end

    payment.save!
  end

  def initialize_payment!
    binding.pry
    self.payment ||= community.payment_gateway.new_payment
    self.payment.payment_gateway ||= community.payment_gateway
    self.payment.conversation = self
    self.payment.status = "pending"
    self.payment.payer = starter
    self.payment.recipient = author
    self.payment.community = community
  end

  def initialize_braintree_payment!(sum, currency)
    payment.sum = Money.new(attributes[:sum], attributes[:currency])
  end

  def initialize_checkout_payment!(rows)
    rows.each { |row| payment.rows.build(row.merge(:currency => "EUR")) unless row["title"].blank? }
  end

  def should_notify?(user)
    status == "pending" && author == user
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

  def waiting_feedback_from?(person)
    !(has_feedback_from?(person) || feedback_skipped_by?(person))
  end

  def has_feedback_from_all_participants?
    participations.each { |p| return false if p.feedback_can_be_given? }
    return true
  end

  def offerer
    participants.find { |p| listing.offerer?(p) }
  end

  def requester
    participants.find { |p| listing.requester?(p) }
  end

  def payer
    starter
  end

  def payment_receiver
    author
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

  def with_type(&block)
    block.call(:listing_conversation)
  end
end