module PaypalService
  module PaypalServiceInjector
    def payment
      @payment ||= build_paypal_payment
    end

    module_function

    def build_paypal_payment
      config = { #define builder here - add a datatype?
        request_cancel: ->(id) {
          TransactionService::Transaction.token_cancelled(id)
        }
      }

      PaypalService::API::Payments.new(config)
    end
  end
end
