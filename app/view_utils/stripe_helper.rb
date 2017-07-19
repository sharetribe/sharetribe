module StripeHelper

  TxApi = TransactionService::API::Api

  module_function

  def community_ready_for_payments?(community_id)
    stripe_active?(community_id) &&
      Maybe(TxApi.settings.get(community_id: community_id, payment_gateway: :stripe, payment_process: :preauthorize))
      .map {|res| res[:success] ? res[:data] : nil}
      .select {|set| set[:commission_from_seller] && set[:minimum_price_cents]}
      .map {|_| true}
      .or_else(false)
  end

  def stripe_active?(community_id)
    active_settings = Maybe(TxApi.settings.get(community_id: community_id, payment_gateway: :stripe, payment_process: :preauthorize))
      .select { |result| result[:success] }
      .map { |result| result[:data] }
      .or_else(nil)

    return active_settings && active_settings[:active] && active_settings[:api_verified]
  end

  def stripe_provisioned?(community_id)
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
    user = Person.find(person_id)
    account && account[:stripe_seller_id].present? && account[:stripe_bank_id] && !user.preferences[:no_stripe]
  end

  def publishable_key(community_id)
    return nil unless StripeHelper.stripe_active?(community_id)
    payment_settings = TransactionService::API::Api.settings.get_active_by_gateway(community_id: community_id, payment_gateway: :stripe).maybe.get
    payment_settings[:api_publishable_key]
  end

  def estimate_stripe_fee(community_id, goal_total, author_id, starter_id)
    return nil unless StripeHelper.stripe_active?(community_id)

    platform_country = StripeService::API::Api.wrapper.platform_country(community_id)

    case StripeService::API::Api.wrapper.destination(community_id)
    when :platform
      target_country = platform_country
    when :seller
      seller_account = StripeService::API::Api.accounts.get(community_id: community_id, person_id: starter_id).data
      target_country = seller_account && seller_account[:address_country] || platform_country
    end

    payer_account = StripeService::API::Api.accounts.get(community_id: community_id, person_id: starter_id).data
    source_country =  payer_account && payer_account[:stripe_source_country].present? ? payer_account[:stripe_source_country] : target_country

    case StripeService::API::Api.wrapper.fee_mode(community_id)
    when :put_on_buyer
      new_total = StripeService::API::FeeCalculator.total_with_fee goal_total, target_country, source_country
    when :put_on_seller
      new_total = goal_total
    end
    new_total - goal_total
  end

  # Check if the user has open listings in the community but has not
  # finished connecting his paypal account.
  def open_listings_with_missing_payment_info?(user_id, community_id)
    stripe_active?(community_id) &&
      !user_and_community_ready_for_payments?(user_id, community_id) &&
      PaypalHelper.open_listings_with_payment_process?(community_id, user_id)
  end
end
