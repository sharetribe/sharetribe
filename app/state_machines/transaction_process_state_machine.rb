class TransactionProcessStateMachine
  include Statesman::Machine

  state :not_started, initial: true
  state :free
  state :initiated
  state :pending  # Deprecated
  state :payment_intent_requires_action
  state :preauthorized
  state :pending_ext
  state :accepted # Deprecated
  state :rejected
  state :errored
  state :paid
  state :confirmed
  state :canceled
  state :payment_intent_action_expired
  state :payment_intent_failed
  state :refunded
  state :dismissed

  transition from: :not_started,                    to: [:free, :initiated]
  transition from: :initiated,                      to: [:payment_intent_requires_action, :preauthorized]
  transition from: :payment_intent_requires_action, to: [:preauthorized, :payment_intent_action_expired, :payment_intent_failed]
  transition from: :preauthorized,                  to: [:paid, :rejected, :pending_ext, :errored]
  transition from: :pending_ext,                    to: [:paid, :rejected]
  transition from: :paid,                           to: [:confirmed, :canceled]
  transition from: :canceled,                       to: [:refunded, :dismissed]

  after_transition(to: :paid, after_commit: true) do |transaction|
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

  after_transition(to: :rejected, after_commit: true) do |transaction|
    rejecter = transaction.listing.author
    current_community = transaction.community

    Delayed::Job.enqueue(TransactionStatusChangedJob.new(transaction.id, rejecter.id, current_community.id))
  end

  after_transition(to: :confirmed, after_commit: true) do |conversation|
    confirmation = ConfirmConversation.new(conversation, conversation.starter, conversation.community)
    confirmation.confirm!
  end

  after_transition(from: :paid, to: :canceled, after_commit: true) do |conversation|
    confirmation = ConfirmConversation.new(conversation, conversation.starter, conversation.community)
    confirmation.cancel!
  end

  after_transition(to: :payment_intent_requires_action, after_commit: true) do |conversation|
    Delayed::Job.enqueue(TransactionPaymentIntentCancelJob.new(conversation.id), :run_at => TransactionPaymentIntentCancelJob::DELAY.from_now)
  end

  after_transition(to: :payment_intent_failed, after_commit: true) do |transaction|
    reject_transaction(transaction)
  end

  after_transition(to: :payment_intent_action_expired, after_commit: true) do |transaction|
    reject_transaction(transaction)
  end

  after_transition(to: :free, after_commit: true) do |transaction|
    send_new_transaction_email(transaction) if transaction.conversation.payment?
  end

  after_transition(to: :preauthorized, after_commit: true) do |transaction|
    send_new_transaction_email(transaction)
  end

  after_transition(to: :refunded, after_commit: true) do |transaction|
    Delayed::Job.enqueue(TransactionRefundedJob.new(transaction.id, transaction.community_id))
  end

  after_transition(to: :dismissed, after_commit: true) do |transaction|
    Delayed::Job.enqueue(TransactionCancelationDismissedJob.new(transaction.id, transaction.community_id))
    confirmation = ConfirmConversation.new(transaction, transaction.starter, transaction.community)
    confirmation.confirm!
  end

  class << self
    def send_new_transaction_email(transaction)
      if transaction.community.email_admins_about_new_transactions
        Delayed::Job.enqueue(SendNewTransactionEmail.new(transaction.id))
      end
    end

    def reject_transaction(transaction)
      TransactionService::StateMachine.rejected(transaction)
      transaction.update_column(:deleted, true) # rubocop:disable Rails/SkipsModelValidations
    end
  end
end
