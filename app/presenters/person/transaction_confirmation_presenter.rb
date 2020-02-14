class Person::TransactionConfirmationPresenter
  CONFIRM = 'confirm'
  CANCEL = 'cancel'

  attr_reader :community, :user, :params, :action_type

  def initialize(community:, user:, params:)
    @community = community
    @user = user
    @params = params
  end

  def action_type_confirm!
    @action_type = CONFIRM
  end

  def action_type_cancel!
    @action_type = CANCEL
  end

  def confirm?
    action_type == CONFIRM
  end

  def cancel?
    action_type == CANCEL
  end

  def listing
    @listing ||= transaction.listing
  end

  def transaction
    @transaction = community.transactions.find(params[:id])
  end

  def other_person
    transaction.other_party(user)
  end

  def message
    @message = Message.new
  end

  def in_valid_pre_state?
    can_be_confirmed? || can_be_canceled?
  end

  def can_be_confirmed?
    can_transition_to?(:confirmed)
  end

  def can_be_canceled?
    can_transition_to?(:canceled)
  end

  def can_transition_to?(state)
    TransactionService::StateMachine.can_transition_to?(transaction.id, state)
  end

  def give_feedback_value
    !cancel?
  end

  def give_feedback_class
    give_feedback_value ? '' : 'hidden'
  end
end
