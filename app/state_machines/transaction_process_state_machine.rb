class TransactionProcessStateMachine
  include Statesman::Machine

  state :not_started, initial: true
  state :free
  state :initiated
  state :pending  # Deprecated
  state :preauthorized
  state :pending_ext
  state :accepted # Deprecated
  state :rejected
  state :errored
  state :paid
  state :confirmed
  state :canceled

  transition from: :not_started,               to: [:free, :initiated]
  transition from: :initiated,                 to: [:preauthorized]
  transition from: :preauthorized,             to: [:paid, :rejected, :pending_ext, :errored]
  transition from: :pending_ext,               to: [:paid, :rejected]
  transition from: :paid,                      to: [:confirmed, :canceled]

  after_transition(to: :paid) do |transaction|
    payer = transaction.starter
    current_community = transaction.community

    if transaction.booking.present?
      booking = transaction.booking
      automatic_booking_confirmation_at = booking.final_end + 2.days
      ConfirmConversation.new(transaction, payer, current_community).activate_automatic_booking_confirmation_at!(automatic_booking_confirmation_at)
    else
      ConfirmConversation.new(transaction, payer, current_community).activate_automatic_confirmation!
    end

    Delayed::Job.enqueue(SendPaymentReceipts.new(transaction.id))
  end

  after_transition(to: :rejected) do |transaction|
    rejecter = transaction.listing.author
    current_community = transaction.community

    Delayed::Job.enqueue(TransactionStatusChangedJob.new(transaction.id, rejecter.id, current_community.id))
  end

  after_transition(to: :confirmed) do |conversation|
    confirmation = ConfirmConversation.new(conversation, conversation.starter, conversation.community)
    confirmation.confirm!
  end

  after_transition(from: :paid, to: :canceled) do |conversation|
    confirmation = ConfirmConversation.new(conversation, conversation.starter, conversation.community)
    confirmation.cancel!
  end

end
