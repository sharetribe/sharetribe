class ConfirmConversation
  # How many days before transaction is automatically confirmed should we send a reminder?
  REMIND_DAYS_BEFORE_CLOSING = 2

  def initialize(transaction, user, community)
    @transaction = transaction
    @conversation = transaction.conversation
    @user = user
    @participation = @conversation.participations.find_by_person_id(user.id)
    @offerer = transaction.offerer
    @requester = transaction.requester
    @community = community
    @hold_in_escrow = community.payment_gateway && community.payment_gateway.hold_in_escrow
    @payment = transaction.payment
  end

  # Listing confirmed by user
  def confirm!
    Delayed::Job.enqueue(TransactionConfirmedJob.new(@transaction.id, @community.id))
    @conversation.messages.create(:sender_id => @requester.id, :action => "confirm")
    release_escrow if @hold_in_escrow
  end

  # Listing canceled by user
  def cancel!
    Delayed::Job.enqueue(TransactionCanceledJob.new(@transaction.id, @community.id))
    @conversation.messages.create(:sender_id => @offerer.id, :action => "cancel")
    cancel_escrow if @hold_in_escrow
  end

  def update_participation(feedback_given)
    @participation.update_attribute(:is_read, true) if @offerer.eql?(@user)
    @participation.update_attribute(:feedback_skipped, true) unless feedback_given
  end

  def activate_automatic_confirmation!
    automatic_confirmation_at = @transaction.automatic_confirmation_after_days.days.from_now

    automatic_confirmation_job!(automatic_confirmation_at)
    confirmation_reminder_job!(automatic_confirmation_at)
  end

  def activate_automatic_booking_confirmation_at!(automatic_confirmation_at)
    Delayed::Job.enqueue(AutomaticBookingConfirmationJob.new(@transaction.id, @user.id, @community.id), run_at: automatic_confirmation_at, priority: 7)
  end

  private

  def automatic_confirmation_job!(automatic_confirmation_at)
    Delayed::Job.enqueue(AutomaticConfirmationJob.new(@transaction.id, @user.id, @community.id), run_at: automatic_confirmation_at, priority: 7)
  end

  def confirmation_reminder_job!(automatic_confirmation_at)
    reminder_email_at           = automatic_confirmation_at - REMIND_DAYS_BEFORE_CLOSING.days
    activate_reminder           = @community.testimonials_in_use && @transaction.automatic_confirmation_after_days > REMIND_DAYS_BEFORE_CLOSING

    if activate_reminder
      Delayed::Job.enqueue(ConfirmReminderJob.new(@transaction.id, @requester.id, @community.id, REMIND_DAYS_BEFORE_CLOSING), :priority => 10, :run_at => reminder_email_at)
    end
  end

  def release_escrow
    BraintreeService.release_from_escrow(@community, @payment.braintree_transaction_id)
  end

  def cancel_escrow
    Delayed::Job.enqueue(EscrowCanceledJob.new(@transaction.id, @community.id))
    BTLog.info("Escrow canceled by user #{@user.id}, transaction #{@transaction.id}, community #{@community.id}")
  end
end
