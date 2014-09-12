module MarketplaceService
  module PaypalAccount
    EntityUtils = MarketplaceService::EntityUtils
    PaypalAccountModel = ::PaypalAccount

    module Entity
      PaypalAccount = EntityUtils.define_entity(
        :email,
        :api_password,
        :api_signature,
        :person_id,
        :community_id,
        :order_permission_state, # one of :not_requested, :pending, :verified
        :request_token # order permission request token
      )

      module_function

      def paypal_account(paypal_acc_model)
        hash = EntityUtils.model_to_hash(paypal_acc_model)
          .merge(order_permission_to_hash(paypal_acc_model.order_permission))
        PaypalAccount.call(hash)
      end


      def order_permission_to_hash(order_perm_model)
        if (order_perm_model.nil?)
          { order_permission_state: :not_requested }
        elsif (order_perm_model.verification_code.nil?)
          { order_permission_state: :pending }
        else
          { order_permission_state: :verified }
        end
          .merge(EntityUtils.model_to_hash(order_perm_model))
      end
    end

    module Command

      module_function

      def create_personal_account(person_id, community_id, account_data)
        PaypalAccountModel.create!(
          account_data.merge({person_id: person_id, community_id: community_id})
        )
        Result::Success.new
      end

      def create_admin_account(community_id, account_data)
        PaypalAccountModel.create!(
          account_data.merge({community_id: community_id, person_id: nil}))
        Result::Success.new
      end

      def save_pending_permissions_request(person_id, community_id, paypal_username_to, scope, request_token)
        # Create new pending permissions request and save it for the paypal account connected to user and community
        # Ensure that this is the only permission request for the pp account by deleting any previous requests(?)
        raise(NotImplementedError)
      end

      def confirm_pending_permissions_request(person_id, community_id, request_token, verification_code)
        # Should this fail silently in case of no matching permission request?
        raise(NotImplementedError)
      end
    end

    module Query

      module_function

      def personal_account(person_id, community_id)
        Maybe(PaypalAccountModel.where(person_id: person_id, community_id: community_id).includes(:order_permission).first)
          .map { |model| Entity.paypal_account(model) }
          .or_else(nil)
      end

      def admin_account(community_id)
        Maybe(PaypalAccountModel.where(community_id: community_id, person_id: nil).includes(:order_permission).first)
          .map { |model| Entity.paypal_account(model) }
          .or_else(nil)
      end
    end
  end
end
