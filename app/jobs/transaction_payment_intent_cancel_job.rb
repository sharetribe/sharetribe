# If the payment intent is not successfully confirmed within 15 minutes,
# the transaction will automatically go to an expired state
# e.g. :payment_intent_action_expired that will not block availability.
class TransactionPaymentIntentCancelJob < Struct.new(:transaction_id)

  DELAY = 15.minutes

  include DelayedAirbrakeNotification

  def perform
    return unless tx

    TransactionService::StateMachine.transition_to(tx.id, :payment_intent_action_expired)
  end

  private

  # Transaction after 15 min of payment_intent_requires_action still has same state
  def tx
    @tx ||= Transaction.find_by(id: transaction_id, current_state: 'payment_intent_requires_action')
  end
end
