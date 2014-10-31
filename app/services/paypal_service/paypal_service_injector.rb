module PaypalService
  module PaypalServiceInjector

    def payments_api
      @payment ||= build_paypal_payments
    end

    def billing_agreement_api
      @billing_agreement ||= PaypalService::API::BillingAgreements.new
    end

    module_function

    def build_paypal_payments
      print_event_dummy = -> (event, payload) {
        puts "Event #{event} triggered with payload: #{payload}"
      }

      events = Events.new({
          request_cancelled: -> (token) {
            TransactionService::PaypalEvents.request_cancelled(token)
          },
          payment_created: [],
          payment_updated: -> (payment) { TransactionService::PaypalEvents.payment_updated(payment) }
      })

      PaypalService::API::Payments.new(events, PaypalService::MerchantInjector.build_paypal_merchant)
    end
  end
end
