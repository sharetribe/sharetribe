require_relative '../test_events'
require_relative '../test_logger'
require_relative '../test_merchant'
require_relative '../test_permissions'
require_relative '../test_api'
require "#{Rails.root}/app/services/paypal_service/paypal_service_injector"

# Rewrite PaypalService::API::Api to inject test paypal client
module PaypalService
  module API
    class FakeApiImplementation
      extend PaypalService::PaypalServiceInjector

      def self.payments
        @payments ||= build_test_payments(allow_async: false, events: events)
      end

      def self.billing_agreements
        @billing_agreements ||= build_billing_agreements
      end

      def self.minimum_commissions
        minimum_commissions_api
      end

      def self.process
        process_api
      end

      def self.accounts
        @accounts ||= build_test_accounts(prepend_country_code: false)
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

      def self.build_test_events
        PaypalService::TestEvents.new
      end

      def self.build_test_payments(allow_async: true, events:)
        payments = PaypalService::API::Payments.new(
          events,
          test_merchant,
          PaypalService::TestLogger.new,
          allow_async: allow_async)
      end

      def self.build_test_accounts(prepend_country_code: false)
        PaypalService::API::Accounts.new(
          test_permissions,
          test_merchant,
          test_onboarding,
          PaypalService::TestLogger.new,
          prepend_country_code: prepend_country_code)
      end

      def self.build_billing_agreements
        PaypalService::API::BillingAgreements.new(test_merchant)
      end
    end
  end
end
