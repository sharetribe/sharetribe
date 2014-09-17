class PaypalWebhooksController < ApplicationController
  include PaypalService::MerchantInjector

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

  def billing_agreement_success_hook

    affirm_agreement_res = affirm_billing_agreement(params[:token])
    if affirm_agreement_res[:success]
      billing_agreement_id = affirm_agreement_res[:billing_agreement_id]

      success = MarketplaceService::PaypalAccount::Command
        .confirm_billing_agreement(@current_user.id, @current_community.id, params[:token], billing_agreement_id)
      redirect_to show_paypal_account_settings_payment_path(@current_user.username)
    else
      flash[:error] = t("paypal_accounts.new.billing_agreement_id_missing")
      redirect_to new_paypal_account_settings_payment_path(@current_user.username)
    end
  end

  def billing_agreement_cancel_hook
    MarketplaceService::PaypalAccount::Command
      .cancel_pending_billing_agreement(@current_user.id, @current_community.id, params[:token])

    flash[:error] = t("paypal_accounts.new.billing_agreement_canceled")
    redirect_to new_paypal_account_settings_payment_path(@current_user.username)
  end


  private

  def affirm_billing_agreement(token)
    affirm_billing_agreement_req = PaypalService::DataTypes::Merchant
      .create_create_billing_agreement(token)

    response = paypal_merchant.do_request(affirm_billing_agreement_req)
  end
end
