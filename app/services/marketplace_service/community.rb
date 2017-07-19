module MarketplaceService
  module Community
    CommunityModel = ::Community

    module Entity
      # module_function
    end

    module Command

      # module_function

    end

    module Query

      TxApi = TransactionService::API::Api

      module_function

      def payment_type(community_id)
        Maybe(CommunityModel.find_by_id(community_id))
          .map { |community|
            supported = []
            supported << :paypal if PaypalHelper.paypal_active?(community.id)
            supported << :stripe if StripeHelper.stripe_active?(community.id)
            supported.size > 1 ? supported : supported.first
          }
          .or_else(nil)
      end
    end
  end
end
