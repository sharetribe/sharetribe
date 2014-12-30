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
      module_function

      def payment_type(community_id)
        Maybe(CommunityModel.find_by_id(community_id))
          .map { |community|
            if community.paypal_enabled
              :paypal
            elsif community.payment_gateway.present?
              community.payment_gateway.gateway_type
            else
              nil
            end
          }
          .or_else(nil)
      end

      def current_plan(community_id)
        CommunityPlan
          .where(:community_id => community_id)
          .order("created_at DESC")
          .first
      end

      def is_plan_expired(community_id)
        Maybe(current_plan(community_id))
          .map { |plan|
            plan.expires_at.present? && plan.expires_at < DateTime.now
          }
          .or_else(false)
      end

    end
  end
end
