module PaypalHelper
  PaypalAccountEntity = PaypalService::PaypalAccount::Entity
  PaypalAccountQuery = PaypalService::PaypalAccount::Query

  TxApi = TransactionService::API::Api

  module_function

  def personal_account_prepared?(user, community)
    paypal_account = PaypalAccountQuery.personal_account(user.id, community.id)
    PaypalAccountEntity.paypal_account_prepared?(paypal_account)
  end

  def community_ready_for_payments?(community_id)
    admin_account = PaypalAccountQuery.admin_account(community_id)
    PaypalAccountEntity.order_permission_verified?(admin_account) &&
      Maybe(TransactionService::API::Api.settings.get_active(community_id: community_id))
      .map {|res| res[:success] ? res[:data] : nil}
      .select {|set| set[:payment_gateway] == :paypal && set[:commission_from_seller] && set[:minimum_price_cents]}
      .map {|_| true}
      .or_else(false)
  end

  def user_and_community_ready_for_payments?(user, community)
    PaypalHelper.personal_account_prepared?(user, community) &&
      PaypalHelper.community_ready_for_payments?(community.id)
  end

  # Check if PayPal has been provisioned for a community.
  #
  # This is different from PayPal being active. Provisioned just means
  # that admin can configure and activate PayPal.
  def paypal_provisioned?(community_id)
    settings = Maybe(TxApi.settings.get(
                      community_id: community_id,
                      payment_gateway: :paypal,
                      payment_process: :preauthorize))
      .select { |result| result[:success] }
      .map { |result| result[:data] }
      .or_else(nil)

    return settings && settings[:payment_gateway] == :paypal
  end

  def paypal_active?(community_id)
    active_settings = Maybe(TxApi.settings.get_active(community_id: community_id))
      .select { |result| result[:success] }
      .map { |result| result[:data] }
      .or_else(nil)

    return active_settings && active_settings[:payment_gateway] == :paypal
  end

  def open_listings_with_missing_payment_info?(user, community)
    paypal_active?(community.id) &&
    !MarketplaceService::Listing::Query.open_listings_for(community.id, user.id).empty? &&
    !user_and_community_ready_for_payments?(user, community)
  end
end
