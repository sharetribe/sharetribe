module TransactionService::Process
  class Postpay

    def create(tx:, gateway_fields:, gateway_adapter:, prefer_async:)
      Transition.transition_to(tx[:id], :pending)

      Result::Success.new({result: true})
    end

  end
end
