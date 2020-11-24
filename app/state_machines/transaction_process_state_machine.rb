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
  state :disputed

  transition from: :not_started,                    to: [:free, :initiated]
  transition from: :initiated,                      to: [:payment_intent_requires_action, :preauthorized]
  transition from: :payment_intent_requires_action, to: [:preauthorized, :payment_intent_action_expired, :payment_intent_failed]
  transition from: :preauthorized,                  to: [:paid, :rejected, :pending_ext, :errored]
  transition from: :pending_ext,                    to: [:paid, :rejected]
  transition from: :paid,                           to: [:confirmed, :canceled, :disputed]
  transition from: :disputed,                       to: [:refunded, :dismissed]

  after_transition do |transaction, transition|
    transaction.update_columns( # rubocop:disable Rails/SkipsModelValidations
      current_state: transition.to_state,
      last_transition_at: Time.current)
  end

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

  # "guard_transition" is before SQL BEGIN-COMMIT block
  # instead, "before_transition" is inside the block
  before_transition(to: :preauthorized) do |transaction, transition|
    validate_before_preauthorized(transaction, transition)
  end

  before_transition(to: :payment_intent_requires_action) do |transaction, transition|
    validate_before_preauthorized(transaction, transition)
  end

  after_transition_failure(to: :preauthorized) do |transaction|
    void_payment(transaction)
  end

  after_transition_failure(to: :payment_intent_action_expired) do |transaction|
    void_payment(transaction)
  end

  after_transition(to: :preauthorized, after_commit: true) do |transaction|
    send_new_transaction_email(transaction)
    handle_preauthorized(transaction)
  end

  after_transition(to: :refunded, after_commit: true) do |transaction|
    transaction.update(starter_skipped_feedback: false)
    Delayed::Job.enqueue(TransactionRefundedJob.new(transaction.id, transaction.community_id))
  end

  after_transition(to: :dismissed, after_commit: true) do |transaction|
    transaction.update(starter_skipped_feedback: false)
    Delayed::Job.enqueue(TransactionCancellationDismissedJob.new(transaction.id, transaction.community_id))
    confirmation = ConfirmConversation.new(transaction, transaction.starter, transaction.community)
    confirmation.confirm!
  end

  after_transition(from: :paid, to: :disputed, after_commit: true) do |transaction|
    Delayed::Job.enqueue(TransactionDisputedJob.new(transaction.id, transaction.community.id))
  end

  class << self
    def send_new_transaction_email(transaction)
      if transaction.community.email_admins_about_new_transactions
        Delayed::Job.enqueue(SendNewTransactionEmail.new(transaction.id))
      end
    end

    def reject_transaction(transaction)
      transaction.update_column(:deleted, true) # rubocop:disable Rails/SkipsModelValidations
    end

    def handle_preauthorized(transaction)
      expiration_period = TransactionService::Transaction.authorization_expiration_period(transaction.payment_gateway)
      gateway_expires_at = case transaction.payment_gateway
                           when :paypal
                             # expiration period in PayPal is an estimate,
                             # which should be quite accurate. We can get
                             # the exact time from Paypal through IPN notification. In this case,
                             # we take the 3 days estimate and add 10 minute buffer
                             expiration_period.days.from_now - 10.minutes
                           when :stripe
                             expiration_period.days.from_now - 10.minutes
                           else
                             raise ArgumentError.new("Unknown payment_type: '#{transaction.payment_gateway}'")
                           end

      booking_ends_on = transaction.booking&.final_end
      expire_at = TransactionService::Transaction.preauth_expires_at(gateway_expires_at, booking_ends_on)

      Delayed::Job.enqueue(TransactionPreauthorizedJob.new(transaction.id), priority: 5)

      # if enabled it will reject Paypal payment under test environment
      unless Rails.env.test?
        Delayed::Job.enqueue(AutomaticallyRejectPreauthorizedTransactionJob.new(transaction.id), priority: 8, run_at: expire_at)
      end

      setup_preauthorize_reminder(transaction.id, expire_at)
    end

    def setup_preauthorize_reminder(transaction_id, expire_at)
      reminder_days_before = 1

      reminder_at = expire_at - reminder_days_before.day
      send_reminder = reminder_at > Time.zone.now

      if send_reminder
        Delayed::Job.enqueue(TransactionPreauthorizedReminderJob.new(transaction_id), priority: 9, :run_at => reminder_at)
      end
    end

    def void_payment(tx)
      gateway_adapter = TransactionService::Transaction.gateway_adapter(tx.payment_gateway)
      void_res = gateway_adapter.reject_payment(tx: tx, reason: "")[:response]

      void_res.on_success {
        logger.info("Payment voided after failed transaction", :void_payment, tx.slice(:community_id, :id))
      }.on_error { |payment_error_msg, payment_data|
        logger.error("Failed to void payment after failed booking", :failed_void_payment, tx.slice(:community_id, :id).merge(error_msg: payment_error_msg))
      }
      void_res
    end

    def logger
      SharetribeLogger.new(:transaction_transition_events)
    end

    def validate_before_preauthorized(transaction, transition)
      Listing.lock.find(transaction.listing_id)
      unless transaction.valid? && (transaction.booking ? transaction.booking.valid? : true)
        raise Statesman::TransitionFailedError.new(transaction.current_state, transition.to_state)
      end
    end
  end
end
