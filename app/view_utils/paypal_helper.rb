module PaypalHelper
  PaypalAccountEntity = PaypalService::PaypalAccount::Entity
  PaypalAccountQuery = PaypalService::PaypalAccount::Query

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
end
