class PaypalIpnController < ApplicationController

  include PaypalService::MerchantInjector
  include PaypalService::IPNInjector

  skip_before_action :verify_authenticity_token,
                     :fetch_logged_in_user,
                     :fetch_community,
                     :perform_redirect,
                     :fetch_community_membership,
                     :check_http_auth

  IPNDataTypes = PaypalService::DataTypes::IPN

  def ipn_hook
    logger = PaypalService::Logger.new
    api = paypal_merchant.build_api(nil)

    if api.ipn_valid?(request.raw_post)  # return true if PP backend verifies the msg
      ipn_service.store_and_create_handler(params.to_unsafe_hash)
    else
      logger.warn("Fake IPN message received: #{request.raw_post}")
    end

    # We received the message ok, so send back 200 OK with empty body
    render body: nil
  end
end
