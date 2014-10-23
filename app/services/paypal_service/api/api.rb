module PaypalService::API
  class Api
    extend PaypalService::PaypalServiceInjector

    def self.payments
      payments_api #PaypalServiceInjector provides readily configured payments api
    end
    def self.billing_agreements
      billing_agreement_api #PaypalServiceInjector provides readily configured payments api
    end
  end
end
