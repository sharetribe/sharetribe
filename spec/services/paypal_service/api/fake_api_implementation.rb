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
      include PaypalService::PaypalServiceInjector

      def initialize(store)
        @store = store
      end

      def payments
        @payments ||= build_test_payments(events: events)
      end

      def billing_agreements
        @billing_agreements ||= build_billing_agreements
      end

      def minimum_commissions
        minimum_commissions_api
      end

      def process
        process_api
      end

      def accounts
        @accounts ||= build_test_accounts(prepend_country_code: false)
      end

      def api_builder
        @api_builder ||= PaypalService::TestApiBuilder.new
      end

      def test_merchant
        @test_merchant ||= PaypalService::TestMerchant.build(api_builder, @store)
      end

      def test_permissions
        @test_permissions ||= PaypalService::TestPermissions.build(api_builder, @store)
      end

      def test_onboarding
        @test_onboarding ||= PaypalService::Onboarding.new(
          {api_credentials: {partner_id: "partner-id"},
           endpoint: {endpoint_name: "sandbox"}})
      end

      def reset!
        @store.reset!
        @payments = nil
        @events = nil
        @billing_agreements = nil
        @test_merchant = nil
        @test_permissions = nil
        @api_builder = nil
      end

      def build_test_events
        PaypalService::TestEvents.new
      end

      def build_test_payments(events:)
        payments = PaypalService::API::Payments.new(
          events,
          test_merchant,
          PaypalService::TestLogger.new)
      end

      def build_test_accounts(prepend_country_code: false)
        PaypalService::API::Accounts.new(
          test_permissions,
          test_merchant,
          test_onboarding,
          PaypalService::TestLogger.new,
          prepend_country_code: prepend_country_code)
      end

      def build_billing_agreements
        PaypalService::API::BillingAgreements.new(test_merchant)
      end
    end
  end
end
