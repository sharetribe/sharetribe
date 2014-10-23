module PaypalService
  module PaypalServiceInjector
    def payments_api
      @payment ||= build_paypal_payments
    end

    module_function

    def build_paypal_payments
      config = { #define builder here - add a datatype?
        request_cancel: ->(token) {
          TransactionService::Transaction.token_cancelled(token)
        },
        authorize: -> (transaction_id) {
          MarketplaceService::Transaction::Command.transition_to(transaction_id, "preauthorized")
        }
      }

      PaypalService::API::Payments.new(config)
    end
  end
end
