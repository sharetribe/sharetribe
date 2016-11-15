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

    def accounts_api
      @accounts_api ||= build_paypal_accounts
    end

    module_function

    def load_minimum_commissions
      path = "#{Rails.root}/app/services/paypal_service/minimum_commissions.yml"
      YAML.load_file(path)
    end

    def build_billing_agreements
      PaypalService::API::BillingAgreements.new(PaypalService::MerchantInjector.build_paypal_merchant)
    end

    def events
      Events.new(
        request_cancelled: -> (flow, token) {
          TransactionService::PaypalEvents.request_cancelled(flow, token)
        },
        order_details: -> (flow, details) {
          TransactionService::PaypalEvents.update_transaction_details(flow, details)
        },
        payment_created: -> (flow, payment) {
          TransactionService::PaypalEvents.payment_updated(flow, payment)
        },
        payment_updated: -> (flow, payment) {
          TransactionService::PaypalEvents.payment_updated(flow, payment)
        }
      )
    end

    def build_paypal_payments
      PaypalService::API::Payments.new(
        events,
        PaypalService::MerchantInjector.build_paypal_merchant)
    end

    def build_paypal_accounts
      PaypalService::API::Accounts.new(
        PaypalService::PermissionsInjector.build_paypal_permissions,
        PaypalService::MerchantInjector.build_paypal_merchant,
        PaypalService::OnboardingInjector.build_paypal_onboarding,
        prepend_country_code: true)
    end
  end
end
