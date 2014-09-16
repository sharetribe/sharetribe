class PaypalWebhooksController < ApplicationController

  skip_before_filter :verify_authenticity_token
  skip_filter :check_email_confirmation, :dashboard_only

  before_filter do
    unless @current_community.paypal_enabled?
      render :nothing => true, :status => 400 and return
    end
  end


  def permissions_hook

    order_permission = MarketplaceService::PaypalAccount::Command
      .confirm_pending_permissions_request(
        @current_user.id,
        @current_community.id,
        params[:request_token],
        params[:verification_code]
      )

    if params[:verification_code].present? && order_permission
      redirect_to new_paypal_account_settings_payment_path(@current_user.username)
    else
      personal_account = MarketplaceService::PaypalAccount::Query.personal_account(@current_user.id, @current_community.id)
      if personal_account && personal_account.order_permission_state != :verified
        MarketplaceService::PaypalAccount::Command.destroy_personal_account(@current_user.id, @current_community.id)
      end
      flash[:error] = t("paypal_accounts.new.permissions_not_granted")
      redirect_to new_paypal_account_settings_payment_path(@current_user.username)
    end
  end

end
