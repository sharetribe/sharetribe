class ConfirmConversation
  def initialize(conversation, user, community)
    @conversation = conversation
    @user = user
    @participation = conversation.participations.find_by_person_id(user.id)
    @offerer = conversation.offerer
    @community = community
    @hold_in_escrow = community.payment_gateway && community.payment_gateway.hold_in_escrow
    @payment = conversation.payment
  end

  def confirm!(feedback_given)
    update_participation(feedback_given)
    Delayed::Job.enqueue(TransactionConfirmedJob.new(@conversation.id, @community.id))
    release_escrow if @hold_in_escrow
  end

  def cancel!(feedback_given)
    update_participation(feedback_given)
    Delayed::Job.enqueue(TransactionCanceledJob.new(@conversation.id, @community.id))
    cancel_escrow if @hold_in_escrow
  end

  def automatic_confirm!
    Delayed::Job.enqueue(TransactionAutomaticallyConfirmedJob.new(@conversation.id, @community.id)) # sent to requester
    Delayed::Job.enqueue(TransactionConfirmedJob.new(@conversation.id, @community.id)) # sent to offerer
    release_escrow if @hold_in_escrow
  end

  private

  def update_participation(feedback_given)
    @participation.update_attribute(:is_read, true) if @offerer.eql?(@user)
    @participation.update_attribute(:feedback_skipped, true) unless feedback_given && feedback_given.eql?("true")
  end

  def release_escrow
    BraintreeService.release_from_escrow(@community, @payment.braintree_transaction_id)
  end

  def cancel_escrow
    Delayed::Job.enqueue(EscrowCanceledJob.new(@conversation.id, @community.id))
    BTLog.info("Escrow canceled by user #{@user.id}, conversation #{@conversation.id}, community #{@community.id}")
  end

end