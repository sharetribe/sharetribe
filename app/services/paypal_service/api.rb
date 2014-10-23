module PaypalService
  class Api
    extend PaypalService::PaypalServiceInjector

    def self.payments
      payments #PaypalServiceInjector provides readily configured payments api
    end
  end
end
