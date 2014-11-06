require_relative 'test_events'
require_relative 'test_logger'
require_relative 'test_merchant'

# Rewrite PaypalService::API::Api to inject test paypal client
module PaypalService::API
  class Api
    def self.payments
      @payments ||= build_test_payments
    end

    def self.billing_agreements
      @billing_agreements ||= build_billing_agreements
    end

    def self.events
      @events ||= PaypalService::TestEvents.new
    end

    def self.api_builder
      @api_builder ||= PaypalService::TestApiBuilder.new
    end

    def self.test_merchant
      @test_merchant ||= PaypalService::TestMerchant.build(api_builder)
    end

    def self.reset!
      @payments = nil
      @events = nil
      @test_merchant = nil
      @api_builder = nil
    end

    def self.build_test_payments
      payments = PaypalService::API::Payments.new(
        events,
        test_merchant,
        PaypalService::TestLogger.new)
    end

    def self.build_billing_agreements
      PaypalService::API::BillingAgreements.new(test_merchant)
    end
  end
end
