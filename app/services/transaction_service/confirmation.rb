class TransactionService::Confirmation
  attr_reader :community, :user, :params

  def initialize(community:, user:, params:)
    @community = community
    @user = user
    @params = params
  end

  def process
    return false unless can_transition_to?

    complete_or_cancel_tx
    confirmation = ConfirmConversation.new(transaction, user, community)
    confirmation.update_participation(give_feedback)
    true
  end

  def transaction
    @transaction = community.transactions.find(params[:id])
  end

  def status
    params[:transaction][:status].to_sym
  end

  def can_transition_to?
    TransactionService::StateMachine.can_transition_to?(transaction.id, status)
  end

  def complete_or_cancel_tx
    data = {
      community_id: community.id,
      transaction_id: transaction.id,
      message: message,
      sender_id: user.id,
      metadata: {
        user_id: user.id
      }
    }
    if status == :confirmed
      TransactionService::Transaction.complete(data)
    else
      TransactionService::Transaction.cancel(data)
    end
  end

  def message
    if(params[:message])
      message = Message.new(params.require(:message).permit(:content).merge({ conversation_id: transaction.conversation.id }))
      if(message.valid?)
        message.content
      end
    end
  end

  def flash_notice
    I18n.t("layouts.notifications.offer_#{status}")
  end

  def give_feedback
    @give_feedback ||= params.try(:[], :give_feedback) == 'true'
  end
end

