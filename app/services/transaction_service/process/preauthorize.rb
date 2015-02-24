module TransactionService::Process
  class Preauthorize

    def create(tx:, gateway_fields:, gateway_adapter:, prefer_async:)
      gateway_adapter.create_payment(tx: tx,
                                     gateway_fields: gateway_fields,
                                     prefer_async: prefer_async)
    end

    def reject(tx:, gateway_adapter:)
    end

    def complete_preauthorization(tx:, gateway_adapter:)
    end
  end
end
