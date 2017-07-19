module TransactionService::Gateway
  class PaypalSettingsAdapter < SettingsAdapter

    PaymentSettingsStore = TransactionService::Store::PaymentSettings

    def configured?(community_id:, author_id:)
      payment_settings = Maybe(PaymentSettingsStore.get_active_by_gateway(community_id: community_id, payment_gateway: :paypal))
                         .select {|set| paypal_settings_configured?(set)}

      personal_account_verified = paypal_account_verified?(community_id: community_id, person_id: author_id, settings: payment_settings)
      community_account_verified = paypal_account_verified?(community_id: community_id)
      payment_settings_available = payment_settings.map {|_| true }.or_else(false)

      [personal_account_verified, community_account_verified, payment_settings_available].all?
    end

    def tx_process_settings(opts_tx)
      currency = opts_tx[:unit_price].currency
      p_set = PaymentSettingsStore.get_active_by_gateway(community_id: opts_tx[:community_id], payment_gateway: :paypal)

      {minimum_commission: Money.new(p_set[:minimum_transaction_fee_cents], currency),
       commission_from_seller: p_set[:commission_from_seller],
       automatic_confirmation_after_days: p_set[:confirmation_after_days]}
    end

    private

    def paypal_settings_configured?(settings)
      settings[:payment_gateway] == :paypal && !!settings[:commission_from_seller] && !!settings[:minimum_price_cents]
    end

    def paypal_account_verified?(community_id:, person_id: nil, settings: Maybe(nil))
      acc_state = PaypalService::API::Api.accounts.get(community_id: community_id, person_id: person_id)
                  .maybe()
                  .fetch(:state, nil)
                  .or_else(:not_connected)
      commission_type = settings[:commission_type].or_else(nil)

      acc_state == :verified || (acc_state == :connected && commission_type == :none)
    end

  end
end
