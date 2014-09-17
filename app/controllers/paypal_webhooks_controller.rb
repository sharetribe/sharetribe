class PaypalWebhooksController < ApplicationController

  skip_before_filter :verify_authenticity_token
  skip_filter :check_email_confirmation, :dashboard_only

  before_filter do
    unless @current_community.paypal_enabled?
      render :nothing => true, :status => 400 and return
    end
  end


  def permissions_hook

    if params[:verification_code].present?
      MarketplaceService::PaypalAccount::Command
        .confirm_pending_permissions_request(
          @current_user.id,
          @current_community.id,
          params[:request_token],
          params[:verification_code]
        )
      redirect_to new_paypal_account_settings_payment_path(@current_user.username)
    else
      flash[:error] = t("paypal_accounts.new.permissions_not_granted")
      redirect_to new_paypal_account_settings_payment_path(@current_user.username)
    end
  end

end
