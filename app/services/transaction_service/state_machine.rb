module TransactionService

  TransitionMetadata= EntityUtils.define_builder(
    [:paypal_pending_reason, :symbol],
    [:paypal_payment_status, :symbol],
    [:user_id, :string],
    [:executed_by_admin, :bool]
  )

  module StateMachine
    module_function

    # returns nil if cannot do transition
    # returns transaction in case of successful transition
    # returns transaction with errors in case of failed transition
    def transition_to(transaction_id, new_status, metadata = nil)
      new_status = new_status.to_sym
      metadata_hash = Maybe(metadata)
        .map { |data| TransitionMetadata.call(data) }
        .map { |data| HashUtils.compact(data) }
        .or_else(nil)
      transaction = ::Transaction.exist.find_by(id: transaction_id)
      state_machine = TransactionProcessStateMachine.new(transaction, transition_class: TransactionTransition)

      if transaction && state_machine.can_transition_to?(new_status)
        begin
          state_machine.transition_to(new_status, metadata_hash)
        rescue StandardError
          # If transaction failed to transition to it's first state (e.g.
          # :initialized or :free), mark it as delted. Reload is needed, in
          # order to get the clean state of the transaction that is recorded in
          # the db and ensure that the model does not contain leftover unsaved
          # data.
          transaction.reload
          if transaction.current_state.nil?
            transaction.deleted = true
            transaction.save!
          end
          raise
        end
        transaction
      end
    end

    def can_transition_to?(transaction_id, new_status)
      transaction = ::Transaction.exist.find_by(id: transaction_id)
      state_machine = TransactionProcessStateMachine.new(transaction, transition_class: TransactionTransition)

      transaction && state_machine.can_transition_to?(new_status)
    end
  end
end
