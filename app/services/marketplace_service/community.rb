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

      # TODO All payment gateways should migrate to use
      # payment_settings. Currently only PayPal uses it. Completing
      # the change makes this code path unnecessary since community is
      # not anymore in charge of payment gateways.
      def payment_type(community_id)
        Maybe(CommunityModel.find_by_id(community_id))
          .map { |community|
            if paypal_active?(community.id)
              :paypal
            elsif community.payment_gateway.present?
              community.payment_gateway.gateway_type
            else
              nil
            end
          }
          .or_else(nil)
      end

      # Privates
      #

      def paypal_active?(community_id)
        active_settings = Maybe(TxApi.settings.get_active(community_id: community_id))
                          .select { |result| result[:success] }
                          .map { |result| result[:data] }
                          .or_else(nil)

        return active_settings && active_settings[:payment_gateway] == :paypal
      end

    end
  end
end
