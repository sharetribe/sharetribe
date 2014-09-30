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
    transaction.conversation.messages.create(:sender_id => payer.id, :action => "pay")
  end

  after_transition(to: :paid) do |transaction|
    payment = transaction.payment
    payer = payment.payer
    current_community = transaction.community

    if transaction.booking.present?
      automatic_booking_confirmation_at = transaction.booking.end_on + 1.day
      ConfirmConversation.new(transaction, payer, current_community).activate_automatic_booking_confirmation_at!(automatic_booking_confirmation_at)
    else
      transaction.update_attributes(automatic_confirmation_after_days: current_community.automatic_confirmation_after_days)
      ConfirmConversation.new(transaction, payer, current_community).activate_automatic_confirmation!
    end
    Delayed::Job.enqueue(PaymentCreatedJob.new(payment.id, transaction.community.id))
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

  after_transition(to: :preauthorized) do |transaction|
    expire_at = transaction.preauthorization_expire_at
    reminder_days_before = 1
    reminder_at = expire_at - reminder_days_before.day
    send_reminder = reminder_at > DateTime.now

    payment = transaction.payment
    payer = payment.payer
    transaction.conversation.messages.create(:sender_id => payer.id, :action => "pay")

    Delayed::Job.enqueue(TransactionPreauthorizedJob.new(transaction.id), :priority => 10)
    if send_reminder
      Delayed::Job.enqueue(TransactionPreauthorizedReminderJob.new(transaction.id), :priority => 10, :run_at => reminder_at)
    end
    Delayed::Job.enqueue(AutomaticallyRejectPreauthorizedTransactionJob.new(transaction.id), priority: 7, run_at: expire_at)
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
