module TransactionService::Gateway
  class BraintreeSettingsAdapter < SettingsAdapter

    CommunityModel = ::Community
    PersonModel = ::Person

    def configured?(community_id:, author_id:)
      CommunityModel.find(community_id).payment_gateway.can_receive_payments?(PersonModel.find(author_id))
    end
  end
end
