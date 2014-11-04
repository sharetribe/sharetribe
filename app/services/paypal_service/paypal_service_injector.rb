module PaypalService
  module PaypalServiceInjector

    def payments_api
      @payment ||= build_paypal_payments
    end

    def billing_agreement_api
      @billing_agreement ||= PaypalService::API::BillingAgreements.new
    end

    def minimum_commissions_api
      @minimum_commissions ||= PaypalService::API::MinimumCommissions.new(load_minimum_commissions)
    end

    module_function

    def load_minimum_commissions
      path = "#{Rails.root}/app/services/paypal_service/minimum_commissions.yml"
      YAML.load_file(path)
    end

    def build_paypal_payments
      print_event_dummy = -> (event, payload) {
        puts "Event #{event} triggered with payload: #{payload}"
      }

      events = Events.new({
          request_cancelled: -> (source, token) {
            TransactionService::PaypalEvents.request_cancelled(source, token)
          },
          payment_created: [],
          payment_updated: -> (source, payment) { TransactionService::PaypalEvents.payment_updated(source, payment) }
      })

      PaypalService::API::Payments.new(events, PaypalService::MerchantInjector.build_paypal_merchant)
    end
  end
end
