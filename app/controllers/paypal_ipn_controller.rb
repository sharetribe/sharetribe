class PaypalIpnController < ApplicationController

  include PaypalService::MerchantInjector

  skip_before_filter :verify_authenticity_token, :fetch_logged_in_user, :fetch_community, :fetch_community_membership
  skip_filter :check_email_confirmation, :dashboard_only

  def ipn_hook
    api = paypal_merchant.build_api(nil)

    if api.ipn_valid?(request.raw_post)  # return true or false
      # binding.pry
      # params contains the data
    end

    # Send back 200 OK with empty body
    render nothing: true
  end

end
