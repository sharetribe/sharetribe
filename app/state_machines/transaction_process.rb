class TransactionProcess
  include Statesman::Machine

  state :not_started, initial: true
  state :free
  state :pending
  state :preauthorized
  state :accepted
  state :rejected
  state :paid
  state :confirmed
  state :canceled

  transition from: :not_started,               to: [:free, :pending, :preauthorized]
  transition from: :pending,                   to: [:accepted, :rejected]
  transition from: :preauthorized,             to: [:paid, :rejected]
  transition from: :accepted,                  to: [:paid, :canceled]
  transition from: :paid,                      to: [:confirmed, :canceled]

  guard_transition(to: :pending) do |conversation|
    conversation.requires_payment?(conversation.community)
  end

  after_transition(to: :accepted) do |conversation|
    accepter = conversation.listing.author
    current_community = conversation.community

    conversation.update_is_read(accepter)
    Delayed::Job.enqueue(ConversationStatusChangedJob.new(conversation.id, accepter.id, current_community.id))

    [3, 10].each do |send_interval|
      Delayed::Job.enqueue(PaymentReminderJob.new(conversation.id, conversation.payment.payer.id, current_community.id), :priority => 10, :run_at => send_interval.days.from_now)
    end
  end

  after_transition(from: :accepted, to: :paid) do |conversation|
    payment = conversation.payment
    payer = payment.payer
    conversation.messages.create(:sender_id => payer.id, :action => "pay")
  end

  after_transition(to: :paid) do |conversation|
    payment = conversation.payment
    payer = payment.payer
    current_community = conversation.community

    if conversation.booking.present?
      automatic_booking_confirmation_at = conversation.booking.end_on + 1.day
      ConfirmConversation.new(conversation, payer, current_community).activate_automatic_booking_confirmation_at!(automatic_booking_confirmation_at)
    else
      conversation.update_attributes(automatic_confirmation_after_days: current_community.automatic_confirmation_after_days)
      ConfirmConversation.new(conversation, payer, current_community).activate_automatic_confirmation!
    end
    Delayed::Job.enqueue(PaymentCreatedJob.new(payment.id, payment.community.id))
  end

  after_transition(to: :rejected) do |conversation|
    rejecter = conversation.listing.author
    current_community = conversation.community

    conversation.update_is_read(rejecter)
    Delayed::Job.enqueue(ConversationStatusChangedJob.new(conversation.id, rejecter.id, current_community.id))
  end

  after_transition(to: :confirmed) do |conversation|
    confirmation = ConfirmConversation.new(conversation, conversation.starter, conversation.community)
    confirmation.confirm!
  end

  after_transition(to: :canceled) do |conversation|
    confirmation = ConfirmConversation.new(conversation, conversation.starter, conversation.community)
    confirmation.cancel!
  end

  before_transition(from: :preauthorized, to: :rejected) do |conversation|
    transaction_id = conversation.payment.braintree_transaction_id

    result = BraintreeApi.void_transaction(conversation.community, transaction_id)

    if result
      BTLog.info("Voided transaction #{transaction_id}")
    else
      BTLog.error("Could not void transaction #{transaction_id}")
    end
  end

  after_transition(to: :preauthorized) do |conversation|
    expire_at = conversation.preauthorization_expire_at
    reminder_days_before = 1
    reminder_at = expire_at - reminder_days_before.day
    send_reminder = reminder_at > DateTime.now

    payment = conversation.payment
    payer = payment.payer
    conversation.messages.create(:sender_id => payer.id, :action => "pay")

    Delayed::Job.enqueue(TransactionPreauthorizedJob.new(conversation.id), :priority => 10)
    if send_reminder
      Delayed::Job.enqueue(TransactionPreauthorizedReminderJob.new(conversation.id), :priority => 10, :run_at => reminder_at)
    end
    Delayed::Job.enqueue(AutomaticallyRejectPreauthorizedTransactionJob.new(conversation.id), priority: 7, run_at: expire_at)
  end

  before_transition(from: :preauthorized, to: :paid) do |conversation|
    transaction_id = conversation.payment.braintree_transaction_id

    result = BraintreeApi.submit_to_settlement(conversation.community, transaction_id)

    if result
      BTLog.info("Submitted authorized payment #{transaction_id} to settlement")
    else
      BTLog.error("Could not submit authorized payment #{transaction_id} to settlement")
    end
  end
end