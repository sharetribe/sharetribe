module PaypalHelper
  PaypalAccountEntity = PaypalService::PaypalAccount::Entity
  PaypalAccountQuery = PaypalService::PaypalAccount::Query

  TxApi = TransactionService::API::Api

  module_function

  def personal_account_prepared?(user, community)
    paypal_account = PaypalAccountQuery.personal_account(user.id, community.id)
    PaypalAccountEntity.paypal_account_prepared?(paypal_account)
  end

  def community_ready_for_payments?(community)
    admin_account = PaypalAccountQuery.admin_account(community.id)
    community.commission_from_seller.present? &&
      community.minimum_price.present? &&
      PaypalAccountEntity.order_permission_verified?(admin_account)
  end

  def user_and_community_ready_for_payments?(user, community)
    PaypalHelper.personal_account_prepared?(user, community) &&
      PaypalHelper.community_ready_for_payments?(community)
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

end
