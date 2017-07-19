module StripeHelper

  TxApi = TransactionService::API::Api

  module_function

  def community_ready_for_payments?(community_id)
    return false unless FeatureFlagHelper.feature_enabled?(:stripe)
    stripe_active?(community_id) &&
      Maybe(TxApi.settings.get(community_id: community_id, payment_gateway: :stripe, payment_process: :preauthorize))
      .map {|res| res[:success] ? res[:data] : nil}
      .select {|set| set[:commission_from_seller] && set[:minimum_price_cents]}
      .map {|_| true}
      .or_else(false)
  end

  def stripe_active?(community_id)
    return false unless FeatureFlagHelper.feature_enabled?(:stripe)
    active_settings = Maybe(TxApi.settings.get(community_id: community_id, payment_gateway: :stripe, payment_process: :preauthorize))
      .select { |result| result[:success] }
      .map { |result| result[:data] }
      .or_else(nil)

    return active_settings && active_settings[:active] && active_settings[:api_verified]
  end

  def stripe_provisioned?(community_id)
    return false unless FeatureFlagHelper.feature_enabled?(:stripe)
    settings = Maybe(TxApi.settings.get(
                      community_id: community_id,
                      payment_gateway: :stripe,
                      payment_process: :preauthorize))
      .select { |result| result[:success] }
      .map { |result| result[:data] }
      .or_else(nil)

    return !!settings
  end

  def user_and_community_ready_for_payments?(person_id, community_id)
    stripe_active?(community_id) && user_stripe_active?(community_id, person_id)
  end

  def user_stripe_active?(community_id, person_id)
    account = StripeService::API::Api.accounts.get(community_id: community_id, person_id: person_id).data
    account && account[:stripe_seller_id].present? && account[:stripe_bank_id].present? 
  end

  def publishable_key(community_id)
    return nil unless StripeHelper.stripe_active?(community_id)
    payment_settings = TransactionService::API::Api.settings.get_active_by_gateway(community_id: community_id, payment_gateway: :stripe).maybe.get
    payment_settings[:api_publishable_key]
  end

  # Check if the user has open listings in the community but has not
  # finished connecting his paypal account.
  def open_listings_with_missing_payment_info?(user_id, community_id)
    stripe_active?(community_id) &&
      !user_and_community_ready_for_payments?(user_id, community_id) &&
      PaypalHelper.open_listings_with_payment_process?(community_id, user_id)
  end
end
