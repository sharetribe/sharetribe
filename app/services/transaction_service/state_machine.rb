module TransactionService
  TransactionModel = ::Transaction

  class BookingStateChangeError < StandardError
  end

  TransitionMetadata= EntityUtils.define_builder(
    [:paypal_pending_reason, :symbol],
    [:paypal_payment_status, :symbol]
  )

  module StateMachine
    module_function

    def transition_to(transaction_id, new_status, metadata = nil)
      new_status = new_status.to_sym

      if can_transition_to?(transaction_id, new_status)
        transaction = TransactionModel.where(id: transaction_id, deleted: false).first
        old_status = transaction.current_state.to_sym if transaction.current_state.present?
        payment_type = transaction.payment_gateway.to_sym

        handle_transition(transaction, payment_type, old_status, new_status)

        save_transition(transaction, new_status, metadata)
      end
    end

    def save_transition(transaction, new_status, metadata = nil)
      transaction.current_state = new_status
      transaction.save!

      metadata_hash = Maybe(metadata)
        .map { |data| TransitionMetadata.call(data) }
        .map { |data| HashUtils.compact(data) }
        .or_else(nil)

      state_machine = TransactionProcessStateMachine.new(transaction, transition_class: TransactionTransition)
      state_machine.transition_to!(new_status, metadata_hash)

      transaction.touch(:last_transition_at) # rubocop:disable Rails/SkipsModelValidations

      transaction.reload
    end

    def can_transition_to?(transaction_id, new_status)
      transaction = TransactionModel.where(id: transaction_id, deleted: false).first
      if transaction
        state_machine = TransactionProcessStateMachine.new(transaction, transition_class: TransactionTransition)
        state_machine.can_transition_to?(new_status)
      end
    end

    def handle_transition(transaction, payment_type, old_status, new_status)
      case new_status
      when :preauthorized
        preauthorized(transaction, payment_type)
      when :paid
        paid(transaction)
      when :rejected
        rejected(transaction)
      end
    end

    # privates

    def preauthorized(transaction, payment_type)
      expiration_period = TransactionService::Transaction.authorization_expiration_period(payment_type)
      gateway_expires_at = case payment_type
                           when :paypal
                             # expiration period in PayPal is an estimate,
                             # which should be quite accurate. We can get
                             # the exact time from Paypal through IPN notification. In this case,
                             # we take the 3 days estimate and add 10 minute buffer
                             expiration_period.days.from_now - 10.minutes
                           when :stripe
                             expiration_period.days.from_now - 10.minutes
                           else
                             raise ArgumentError.new("Unknown payment_type: '#{payment_type}'")
                           end

      booking_ends_on = transaction.booking&.final_end
      expire_at = TransactionService::Transaction.preauth_expires_at(gateway_expires_at, booking_ends_on)

      Delayed::Job.enqueue(TransactionPreauthorizedJob.new(transaction.id), priority: 5)
      Delayed::Job.enqueue(AutomaticallyRejectPreauthorizedTransactionJob.new(transaction.id), priority: 8, run_at: expire_at)

      setup_preauthorize_reminder(transaction.id, expire_at)
    end

    def paid(transaction)
      return unless (transaction.availability.to_sym == :booking && !transaction.booking.per_hour?)

      community_uuid = UUIDUtils.parse_raw(transaction.community_uuid)
      listing_author_uuid = UUIDUtils.parse_raw(transaction.listing_author_uuid)
      booking_uuid = UUIDUtils.parse_raw(transaction.booking_uuid)

      auth_context = {
        marketplace_id: community_uuid,
        actor_id: listing_author_uuid
      }

      HarmonyClient.post(
        :accept_booking,
        params: {
          id: booking_uuid
        },
        body: {
          actorId: listing_author_uuid,
          reason: :provider_accepted
        },
        opts: {
          max_attempts: 3,
          auth_context: auth_context
        }).on_error { |error_msg, data|
        log_and_notify_harmony_error!("Failed to accept booking",
                                      :failed_accept_booking,
                                      {community_id: transaction.community_id, id: transaction.id, error_msg: error_msg})
      }
    end

    def rejected(transaction)
      return unless (transaction.availability.to_sym == :booking && !transaction.booking.per_hour?)

      community_uuid = UUIDUtils.parse_raw(transaction.community_uuid)
      listing_author_uuid = UUIDUtils.parse_raw(transaction.listing_author_uuid)
      booking_uuid = UUIDUtils.parse_raw(transaction.booking_uuid)

      auth_context = {
        marketplace_id: community_uuid,
        actor_id: listing_author_uuid
      }

      HarmonyClient.post(
        :reject_booking,
        params: {
          id: booking_uuid
        },
        body: {
          actorId: listing_author_uuid,

          # Passing the reason to the event handler is a bit
          # cumbersome. We decided to skip it for now. That's why
          # we always set the reason to "unknown"
          reason: :unknown
        },
        opts: {
          max_attempts: 3,
          auth_context: auth_context
        }).on_error { |error_msg, data|
        log_and_notify_harmony_error!("Failed to reject booking",
                                      :failed_reject_booking,
                                      {community_id: transaction.community_id, id: transaction.id, error_msg: error_msg})
      }
    end

    # "private" helpers

    def setup_preauthorize_reminder(transaction_id, expire_at)
      reminder_days_before = 1

      reminder_at = expire_at - reminder_days_before.day
      send_reminder = reminder_at > Time.zone.now

      if send_reminder
        Delayed::Job.enqueue(TransactionPreauthorizedReminderJob.new(transaction_id), priority: 9, :run_at => reminder_at)
      end
    end

    def log_and_notify_harmony_error!(error_msg, error_code, data)
      logger.error(error_msg, error_code, data)

      Airbrake.notify(BookingStateChangeError.new("#{error_msg}: #{data}")) if APP_CONFIG.use_airbrake
    end

    def logger
      SharetribeLogger.new(:transaction_transition_events)
    end
  end
end
