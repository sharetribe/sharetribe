module TransactionService::Gateway
  class PaypalSettingsAdapter < SettingsAdapter

    PaymentSettingsStore = TransactionService::Store::PaymentSettings

    def configured?(community_id:, author_id:)
      payment_settings = Maybe(PaymentSettingsStore.get_active(community_id: community_id))
                         .select {|set| paypal_settings_configured?(set)}

      personal_account_verified = paypal_account_verified?(community_id: community_id, person_id: author_id, settings: payment_settings)
      community_account_verified = paypal_account_verified?(community_id: community_id)
      payment_settings_available = payment_settings.map {|_| true }.or_else(false)

      [personal_account_verified, community_account_verified, payment_settings_available].all?
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
