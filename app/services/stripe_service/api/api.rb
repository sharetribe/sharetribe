module StripeService
  module API
    class Api
      def self.accounts
        @accounts ||= StripeService::API::Accounts.new
      end

      def self.wrapper
        StripeService::API::StripeApiWrapper
      end

      def self.payments
        StripeService::API::Payments
      end

      def self.minimum_commissions
        @minimum_commissions ||= StripeService::API::MinimumCommissions.new(load_minimum_commissions)
      end

      def self.load_minimum_commissions
        path = "#{Rails.root}/app/services/stripe_service/minimum_commissions.yml"
        YAML.load_file(path)
      end
    end
  end
end
