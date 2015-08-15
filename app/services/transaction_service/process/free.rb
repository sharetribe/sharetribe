module TransactionService::Process
  class Free

    def create(tx:, gateway_fields:, gateway_adapter:, prefer_async:)
      Result::Success.new({result: true})
    end

  end
end
