class PaypalIpnController < ApplicationController

  include PaypalService::MerchantInjector
  include PaypalService::IPNInjector

  skip_before_filter :verify_authenticity_token, :fetch_logged_in_user, :fetch_community, :fetch_community_membership
  skip_filter :check_email_confirmation, :dashboard_only

  IPNDataTypes = PaypalService::DataTypes::IPN

  def ipn_hook
    logger = PaypalService::Logger.new
    api = paypal_merchant.build_api(nil)

    if api.ipn_valid?(request.raw_post)  # return true if PP backend verifies the msg
      msg = IPNDataTypes.from_params(params)

      if (msg[:type] == :unknown)
        logger.warn("Unknown IPN message type: #{params}")
      else
        ipn_service.handle_msg(msg)
      end
    else
      logger.warn("Fake IPN message received: #{request.raw_post}")
    end

    # Send back 200 OK with empty body
    render nothing: true
  end
end
