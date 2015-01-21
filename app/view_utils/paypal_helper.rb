module PaypalHelper
  PaypalAccountEntity = PaypalService::PaypalAccount::Entity
  PaypalAccountQuery = PaypalService::PaypalAccount::Query

  TxApi = TransactionService::API::Api

  module_function

  # Check that we have an active provisioned :paypal payment gateway
  # for the community AND that the community admin has fully
  # configured the gateway.
  def community_ready_for_payments?(community_id)
    admin_account = PaypalAccountQuery.admin_account(community_id)

    PaypalAccountEntity.order_permission_verified?(admin_account) &&
      Maybe(TransactionService::API::Api.settings.get_active(community_id: community_id))
      .map {|res| res[:success] ? res[:data] : nil}
      .select {|set| set[:payment_gateway] == :paypal && set[:commission_from_seller] && set[:minimum_price_cents]}
      .map {|_| true}
      .or_else(false)
  end

  # Check that both the community is fully configured with an active
  # :paypal payment gateway and that the given user has connected his
  # paypal account.
  def user_and_community_ready_for_payments?(user_id, community_id)
    PaypalHelper.personal_account_prepared?(user_id, community_id) &&
      PaypalHelper.community_ready_for_payments?(community_id)
  end

  # Check that the user has connected his paypal account for the
  # community
  def personal_account_prepared?(user_id, community_id)
    paypal_account = PaypalAccountQuery.personal_account(user_id, community_id)
    PaypalAccountEntity.paypal_account_prepared?(paypal_account)
  end

  # Check that the currently active payment gateway (there can be only
  # one active at any time) for the community is :paypal. This doesn't
  # check that the gateway is fully configured. Use
  # community_ready_for_payments? if that's what you need.
  def paypal_active?(community_id)
    active_settings = Maybe(TxApi.settings.get_active(community_id: community_id))
      .select { |result| result[:success] }
      .map { |result| result[:data] }
      .or_else(nil)

    return active_settings && active_settings[:payment_gateway] == :paypal
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

    return !!settings
  end

  # Check if the user has open listings in the community but has not
  # finished connecting his paypal account.
  def open_listings_with_missing_payment_info?(user_id, community_id)
    paypal_active?(community_id) &&
    !user_and_community_ready_for_payments?(user_id, community_id) &&
    !MarketplaceService::Listing::Query.open_listings_for(community_id, user_id).empty?
  end
end
