module PaypalService
  module PaypalServiceInjector

    def payments_api
      @payment ||= build_paypal_payments
    end

    def billing_agreement_api
      @billing_agreement ||= build_billing_agreements
    end

    def minimum_commissions_api
      @minimum_commissions ||= PaypalService::API::MinimumCommissions.new(load_minimum_commissions)
    end

    def process_api
      @process_api ||= PaypalService::API::Process.new
    end

    module_function

    def load_minimum_commissions
      path = "#{Rails.root}/app/services/paypal_service/minimum_commissions.yml"
      YAML.load_file(path)
    end

    def build_billing_agreements
      PaypalService::API::BillingAgreements.new(PaypalService::MerchantInjector.build_paypal_merchant)
    end

    def build_paypal_payments
      print_event_dummy = -> (event, payload) {
        puts "Event #{event} triggered with payload: #{payload}"
      }

      events = Events.new({
          request_cancelled: -> (flow, token) {
            TransactionService::PaypalEvents.request_cancelled(flow, token)
          },
          payment_created: [],
          payment_updated: -> (flow, payment) { TransactionService::PaypalEvents.payment_updated(flow, payment) }
      })

      PaypalService::API::Payments.new(events, PaypalService::MerchantInjector.build_paypal_merchant)
    end
  end
end
