module TransactionService::Process::Transition

  module_function

  # Placeholder implementation that delegates to to-be-removed
  # implementation so processes can start to call the new place
  # already.
    def transition_to(transaction_id, new_status, metadata = nil)
      MarketplaceService::Transaction::Command.transition_to(transaction_id, new_status, metadata)
    end
end
