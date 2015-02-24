module TransactionService::Gateway

  # Stub checkout adapter, not expected to be called at this point.
  class CheckoutAdapter < GatewayAdapter

    def implements_process(process)
      [:none, :postpay].include?(process)
    end

  end
end
