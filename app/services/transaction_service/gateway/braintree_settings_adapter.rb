module TransactionService::Gateway
  class BraintreeSettingsAdapter < SettingsAdapter

    CommunityModel = ::Community
    PersonModel = ::Person

    def configured?(community_id:, author_id:)
      CommunityModel.find(community_id).payment_gateway.can_receive_payments?(PersonModel.find(author_id))
    end

    def tx_process_settings(opts_tx)
      minimum_commission = Maybe(opts_tx[:unit_price]).map { |price| Money.new(0, price.currency) }.or_else(Money.new(0))
      c = CommunityModel.find(opts_tx[:community_id])

      {minimum_commission: minimum_commission,
       commission_from_seller: Maybe(c.commission_from_seller).or_else(0),
       automatic_confirmation_after_days: Maybe(c.automatic_confirmation_after_days).or_else(14)}
    end
  end
end
