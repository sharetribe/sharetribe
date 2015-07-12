module TransactionService::Gateway
  class FreeSettingsAdapter < SettingsAdapter

    CommunityModel = ::Community

    def configured?(community_id:, author_id:)
      true
    end

    def tx_process_settings(opts_tx)
      minimum_commission = Maybe(opts_tx[:unit_price]).map { |price| Money.new(0, price.currency) }.or_else(Money.new(0))
      c = CommunityModel.find(opts_tx[:community_id])

      {minimum_commission: minimum_commission,
       commission_from_seller: 0,
       automatic_confirmation_after_days: 0}
    end
  end
end
