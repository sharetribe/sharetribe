module PaymentHelpers
  def payment_provision(community, payment_gateway)
    TransactionService::API::Api.settings.provision(
      community_id: community.id,
      payment_gateway: payment_gateway,
      payment_process: :preauthorize,
      active: true)
  end

  def payment_enable(community, payment_gateway, commission_from_seller: 10, minimum_price_cents: 100)
    tx_settings_api = TransactionService::API::Api.settings
    if payment_gateway == 'paypal'
      FactoryGirl.create(:paypal_account,
                         community_id: community.id,
                         order_permission: FactoryGirl.build(:order_permission))
    end
    data = {
      community_id: community.id,
      payment_process: :preauthorize,
      payment_gateway: payment_gateway
    }
    tx_settings_api.activate(data)
    tx_settings_api.update(data.merge(
      commission_from_seller: commission_from_seller,
      minimum_price_cents: minimum_price_cents
    ))
    if payment_gateway == 'stripe'
      tx_settings_api.update(data.merge(
        api_private_key: 'sk_test_123456789012345678901234',
        api_publishable_key: 'pk_test_123456789012345678901234'
      ))
      tx_settings_api.api_verified(data)
    end
  end
end

RSpec.configure do |config|
  config.include PaymentHelpers
end
