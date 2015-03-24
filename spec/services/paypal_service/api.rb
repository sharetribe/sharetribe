require_relative 'test_events'
require_relative 'test_logger'
require_relative 'test_merchant'
require_relative 'test_permissions'

# Rewrite PaypalService::API::Api to inject test paypal client
module PaypalService::API
  class Api
    def self.payments
      @payments ||= build_test_payments
    end

    def self.accounts
      @accounts ||= build_test_accounts
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

    def self.test_permissions
      @test_permissions ||= PaypalService::TestPermissions.build(api_builder)
    end

    def self.test_onboarding
      @test_onboarding ||= PaypalService::Onboarding.new(
        {api_credentials: {partner_id: "partner-id"},
         endpoint: {endpoint_name: "sandbox"}})
    end

    def self.reset!
      @payments = nil
      @events = nil
      @billing_agreements = nil
      @test_merchant = nil
      @test_permissions = nil
      @api_builder = nil
    end

    def self.build_test_payments
      payments = PaypalService::API::Payments.new(
        events,
        test_merchant,
        PaypalService::TestLogger.new)
    end

    def self.build_test_accounts
      PaypalService::API::Accounts.new(
        test_permissions,
        test_merchant,
        test_onboarding,
        PaypalService::TestLogger.new)
    end

    def self.build_billing_agreements
      PaypalService::API::BillingAgreements.new(test_merchant)
    end
  end
end
