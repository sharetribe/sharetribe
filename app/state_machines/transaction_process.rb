class TransactionProcess
  include Statesman::Machine

  state :not_started, initial: true
  state :free
  state :pending
  state :accepted
  state :rejected
  state :paid
  state :confirmed
  state :canceled

  transition from: :not_started,               to: [:free, :pending]
  transition from: :pending,                   to: [:accepted, :rejected]
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
        Delayed::Job.enqueue(PaymentReminderJob.new(conversation.id, conversation.payment.payer.id, current_community.id), :priority => 0, :run_at => send_interval.days.from_now)
      end
    else
      ConfirmConversation.new(conversation, accepter, current_community).activate_automatic_confirmation!
    end
  end

  after_transition(to: :paid) do |conversation|
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
end