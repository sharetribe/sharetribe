module FeatureTests
  module Data
    module_function

    def create_marketplace(payment_gateway:)

      marketplace = MarketplaceService.create(
        marketplace_name: "Test marketplace",
        marketplace_type: "product",
        marketplace_country: "us",
        marketplace_language: "en",
        payment_process: :preauthorize
      )

      if payment_gateway
        TransactionService::API::Api.settings.provision(
          community_id: marketplace[:id],
          payment_gateway: payment_gateway,
          payment_process: :preauthorize,
          active: true)
      end
      if payment_gateway == :stripe
        FeatureFlagService::API::Api.features.enable(community_id: marketplace[:id], features: [:stripe])
      end

      {
        id: marketplace[:id],
        ident: marketplace[:ident]
      }
    end

    def create_member(username:, marketplace_id:, admin:)
      u = create_user(username: username, marketplace_id: marketplace_id)
      m = create_membership(user_id: u[:id], marketplace_id: marketplace_id, admin: admin)
      u
    end

    def create_user(username:, marketplace_id:)
      password = "test"

      u = FactoryGirl.create(:person,
        username: username,
        community_id: marketplace_id,
        password: password,
        emails: [
          FactoryGirl.build(:email, address: "#{username}@example.com")
        ]
      )

      {
        id: u.id,
        username: u.username,
        password: password
      }
    end

    def create_membership(user_id:, marketplace_id:, admin: false)
      FactoryGirl.create(:community_membership,
                         person_id: user_id,
                         community_id: marketplace_id,
                         consent: "SHARETRIBE1.0",
                         admin: admin)
    end
  end
end
