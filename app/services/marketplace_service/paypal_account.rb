module MarketplaceService
  module PaypalAccount
    PaypalAccountModel = ::PaypalAccount

    module Entity
      PaypalAccount = Struct.new(
        :email,
        :api_password,
        :api_signature,
        :person_id,
        :community_id
      )

      module_function

      def paypal_account(model)
        hash = EntityUtils.model_attrs_to_hash(model)
        EntityUtils.from_hash(PaypalAccount, hash)
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
    end

    module Query

      module_function

      def personal_account(person_id, community_id)
        Maybe(PaypalAccountModel.where(person_id: person_id, community_id: community_id).first)
          .map { |model| Entity.paypal_account(model) }
          .or_else(nil)
      end

      def admin_account(community_id)
        Maybe(PaypalAccountModel.where(community_id: community_id, person_id: nil).first)
          .map { |model| Entity.paypal_account(model) }
          .or_else(nil)
      end
    end
  end
end
