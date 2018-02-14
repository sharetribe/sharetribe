module PaymentsHelper

  def stripe_default_data
    payment_settings = PaymentSettings.where(community_id: @current_community.id,
                                             payment_gateway: :stripe,
                                             payment_process: :preauthorize).first
    {
      stripe_test_mode: !!StripeService::API::Api.wrapper.test_mode?(@current_community.id),
      api_publishable_key: payment_settings.try(:api_publishable_key),
    }
  end
end
