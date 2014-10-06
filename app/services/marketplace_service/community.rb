module MarketplaceService
  module Community
    CommunityModel = ::Community

    Settings = EntityUtils.define_builder(
      [:payment_type, one_of: [:paypal, :braintree, :checkout, nil]]
    )

    module Entity
      # module_function
    end

    module Command

      # module_function

    end

    module Query
      module_function

      def settings(community_id)
        Maybe(CommunityModel.find_by_id(community_id)).map do |community|
          Settings[{
            payment_type: payment_type(community)
          }]
        end.or_else(nil)
      end

      def payment_type(community)
        if community.paypal_enabled
          :paypal
        elsif community.payment_gateway.present?
          community.payment_gateway.gateway_type
        else
          nil
        end
      end
    end
  end
end
