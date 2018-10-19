module TransactionService::Process
  class Free
    include TransactionProcessHelper

    def create(tx:, gateway_fields:, gateway_adapter:, force_sync:)
      Result::Success.new({result: true})
    end

  end
end
