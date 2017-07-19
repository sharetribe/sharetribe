module TransactionService::Gateway
  class StripeAdapter < GatewayAdapter

    def implements_process(process)
      [:preauthorize].include?(process)
    end

    def create_payment(tx:, gateway_fields:, force_sync:)
      result = stripe_api.payments.create_preauth_payment(tx, gateway_fields)
      SyncCompletion.new(result)
    end

    def reject_payment(tx:, reason: "")
      result = stripe_api.payments.cancel_preauth(tx, reason)
      SyncCompletion.new(result)
    end

    def complete_preauthorization(tx:)
      result = stripe_api.payments.capture(tx)
      SyncCompletion.new(result)
    end

    def get_payment_details(tx:)
      stripe_api.payments.payment_details(tx)
    end

    private

    def stripe_api
      StripeService::API::Api
    end
  end
end
