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
    end
  end
end
