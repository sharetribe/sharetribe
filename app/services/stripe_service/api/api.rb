module StripeService
  module API
    class API
      def self.accounts
        @accounts ||= StripeService::API::Accounts.new
      end

      def self.wrapper
        StripeService::API::StripeAPIWrapper
      end

      def self.payments
        StripeService::API::Payments
      end

      def self.minimum_commissions
        @minimum_commissions ||= StripeService::API::MinimumCommissions.new(load_minimum_commissions)
      end

      def self.load_minimum_commissions
        path = Rails.root.join('config', 'minimum_commissions.yml')
        YAML.load_file(path.to_s)
      end
    end
  end
end
