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

  def confirm_or_cancel!(feedback_given)
    @participation.update_attribute(:is_read, true) if @offerer.eql?(@user)
    @participation.update_attribute(:feedback_skipped, true) unless feedback_given && feedback_given.eql?("true")

    Delayed::Job.enqueue(TransactionConfirmedJob.new(@conversation.id, @community.id))

    if @hold_in_escrow
      if @conversation.status == "confirmed"
        BraintreeService.release_from_escrow(@community, @payment.braintree_transaction_id)
      else
        Delayed::Job.enqueue(EscrowCanceledJob.new(@conversation.id, @community.id))
        BTLog.info("Escrow canceled by user #{@user.id}, conversation #{@conversation.id}, community #{@community.id}")
      end
    end
  end
end