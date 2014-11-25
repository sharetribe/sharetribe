class TransactionProcess
  include Statesman::Machine

  state :not_started, initial: true
  state :free
  state :initiated
  state :pending
  state :preauthorized
  state :pending_ext
  state :accepted
  state :rejected
  state :errored
  state :paid
  state :confirmed
  state :canceled

  transition from: :not_started,               to: [:free, :pending, :preauthorized, :initiated]
  transition from: :initiated,                 to: [:preauthorized]
  transition from: :pending,                   to: [:accepted, :rejected]
  transition from: :preauthorized,             to: [:paid, :rejected, :pending_ext, :errored]
  transition from: :pending_ext,               to: [:paid, :rejected]
  transition from: :accepted,                  to: [:paid, :canceled]
  transition from: :paid,                      to: [:confirmed, :canceled]

  guard_transition(to: :pending) do |conversation|
    conversation.requires_payment?(conversation.community)
  end

  after_transition(to: :accepted) do |transaction|
    accepter = transaction.listing.author
    current_community = transaction.community

    Delayed::Job.enqueue(TransactionStatusChangedJob.new(transaction.id, accepter.id, current_community.id))

    [3, 10].each do |send_interval|
      Delayed::Job.enqueue(PaymentReminderJob.new(transaction.id, transaction.payment.payer.id, current_community.id), :priority => 10, :run_at => send_interval.days.from_now)
    end
  end

  after_transition(from: :accepted, to: :paid) do |transaction|
    payment = transaction.payment
    payer = payment.payer
  end

  after_transition(to: :paid) do |transaction|
    payer = transaction.starter
    current_community = transaction.community

    if transaction.booking.present?
      automatic_booking_confirmation_at = transaction.booking.end_on + 1.day
      ConfirmConversation.new(transaction, payer, current_community).activate_automatic_booking_confirmation_at!(automatic_booking_confirmation_at)
    else
      transaction.update_attributes(automatic_confirmation_after_days: current_community.automatic_confirmation_after_days)
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

  after_transition(from: :accepted, to: :canceled) do |conversation|
    confirmation = ConfirmConversation.new(conversation, conversation.starter, conversation.community)
    confirmation.cancel!
  end

  after_transition(from: :paid, to: :canceled) do |conversation|
    confirmation = ConfirmConversation.new(conversation, conversation.starter, conversation.community)
    confirmation.cancel!
    confirmation.cancel_escrow!
  end

end
