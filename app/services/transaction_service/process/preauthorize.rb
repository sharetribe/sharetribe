module TransactionService::Process
  Gateway = TransactionService::Gateway

  class Preauthorize

    def create(tx:, gateway_fields:, gateway_adapter:, prefer_async:)
      Transition.transition_to(tx[:id], :initiated)

      Gateway.unwrap_completion(
        gateway_adapter.create_payment(
          tx: tx,
          gateway_fields: gateway_fields,
          prefer_async: prefer_async)) do

        Transition.transition_to(tx[:id], :preauthorized)
      end
    end

    def reject(tx:, gateway_adapter:)
      Gateway.unwrap_completion(
        gateway_adapter.reject_payment(tx: tx, reason: "")) do

        Transition.transition_to(tx[:id], :rejected)
      end
    end

    def complete_preauthorization(tx:, gateway_adapter:)
      Gateway.unwrap_completion(
        gateway_adapter.complete_preauthorization(tx: tx)) do

        Transition.transition_to(tx[:id], :paid)
      end
    end
  end
end
