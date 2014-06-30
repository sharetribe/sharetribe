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

    # Copy automatic_confirmation from community settings
    conversation.update_attributes(automatic_confirmation_after_days: current_community.automatic_confirmation_after_days)
    conversation.update_is_read(accepter)
    Delayed::Job.enqueue(ConversationStatusChangedJob.new(conversation.id, accepter.id, current_community.id))

    # Deprecated, non-payment requests are not coming here anymore
    #
    # Suggestion how to remove this:
    # 1) Keep it here for a while, since there might be old conversations that have pending or accepted
    # status even though they do not have payments
    # 2) Migrate all conversations that don't have payments: pending -> free
    if conversation.requires_payment?(current_community)
      [3, 10].each do |send_interval|
        Delayed::Job.enqueue(PaymentReminderJob.new(conversation.id, conversation.payment.payer.id, current_community.id), :priority => 10, :run_at => send_interval.days.from_now)
      end
    else
      ConfirmConversation.new(conversation, accepter, current_community).activate_automatic_confirmation!
    end
  end

  after_transition(from: :accepted, to: :paid) do |conversation|
    payer = conversation.payment.payer
    conversation.messages.create(:sender_id => payer.id, :action => "pay")
    ConfirmConversation.new(conversation, payer, conversation.community).activate_automatic_confirmation!
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
    preauthorization_expiration = 5.days.from_now
    Delayed::Job.enqueue(AutomaticallyRejectPreauthorizedTransactionJob.new(conversation.id), run_at: preauthorization_expiration, priority: 7)
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