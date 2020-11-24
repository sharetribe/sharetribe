module PaypalService::API
  class ApiImplementation
    extend PaypalService::PaypalServiceInjector

    def self.payments
      payments_api #PaypalServiceInjector provides readily configured payments api
    end

    def self.billing_agreements
      billing_agreement_api #PaypalServiceInjector provides readily configured payments api
    end

    def self.minimum_commissions
      minimum_commissions_api
    end

    def self.process
      process_api
    end

    def self.accounts
      accounts_api
    end
  end
end
