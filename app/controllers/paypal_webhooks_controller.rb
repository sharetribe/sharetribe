class PaypalWebhooksController < ApplicationController
  include PaypalService::PermissionsInjector
  include PaypalService::MerchantInjector

  skip_before_filter :verify_authenticity_token
  skip_filter :check_email_confirmation, :dashboard_only

  before_filter do
    unless @current_community.paypal_enabled?
      render :nothing => true, :status => 400 and return
    end
  end

  DataTypePermissions = PaypalService::DataTypes::Permissions
  PaypalAccountCommand = PaypalService::PaypalAccount::Command
  PaypalAccountQuery = PaypalService::PaypalAccount::Query

  def permissions_hook

    unless params[:verification_code].present?
      return flash_error_and_redirect_to_settings(t("paypal_accounts.new.permissions_not_granted"))
    end

    access_token_res = fetch_access_token(params[:request_token], params[:verification_code])
    return flash_error_and_redirect_to_settings unless access_token_res[:success]

    personal_data_res = fetch_personal_data(access_token_res[:token], access_token_res[:token_secret])
    return flash_error_and_redirect_to_settings unless personal_data_res[:success]

    PaypalAccountCommand.update_personal_account(
      @current_user.id,
      @current_community.id,
      {
        email: personal_data_res[:email],
        payer_id: personal_data_res[:payer_id]
      }
    )
    PaypalAccountCommand.confirm_pending_permissions_request(
      @current_user.id,
      @current_community.id,
      params[:request_token],
      access_token_res[:scope].join(","),
      params[:verification_code]
    )
    redirect_to new_paypal_account_settings_payment_path(@current_user.username)

  end

  def billing_agreement_success_hook

    affirm_agreement_res = affirm_billing_agreement(params[:token])
    return flash_error_and_redirect_to_settings unless affirm_agreement_res[:success]

    billing_agreement_id = affirm_agreement_res[:billing_agreement_id]

    express_checkout_details_req = PaypalService::DataTypes::Merchant.create_get_express_checkout_details({token: params[:token]})
    express_checkout_details_res = paypal_merchant.do_request(express_checkout_details_req)

    paypal_account =  PaypalAccountQuery.personal_account(@current_user.id, @current_community.id)
    if !express_checkout_details_res[:billing_agreement_accepted] ||
      express_checkout_details_res[:payer_id] != paypal_account[:payer_id]

      return flash_error_and_redirect_to_settings(t("paypal_accounts.new.billing_agreement_not_accepted"))
    end

    success = PaypalAccountCommand.confirm_billing_agreement(@current_user.id, @current_community.id, params[:token], billing_agreement_id)
    redirect_to show_paypal_account_settings_payment_path(@current_user.username)
  end

  def billing_agreement_cancel_hook
    PaypalAccountCommand.cancel_pending_billing_agreement(@current_user.id, @current_community.id, params[:token])

    flash[:error] = t("paypal_accounts.new.billing_agreement_canceled")
    redirect_to new_paypal_account_settings_payment_path(@current_user.username)
  end

  def admin_permissions_hook
    if params[:verification_code].present?

      access_token_res = fetch_access_token(params[:request_token], params[:verification_code])
      return flash_error_and_redirect_to_settings unless access_token_res[:success]

      personal_data_res = fetch_personal_data(access_token_res[:token], access_token_res[:token_secret])
      return flash_error_and_redirect_to_settings unless personal_data_res[:success]

      PaypalAccountCommand.update_admin_account(
        @current_community.id,
        {
          email: personal_data_res[:email],
          payer_id: personal_data_res[:payer_id]
        }
      )
      PaypalAccountCommand.confirm_pending_permissions_request(
        nil,
        @current_community.id,
        params[:request_token],
        access_token_res[:scope].join(","),
        params[:verification_code]
      )

      redirect_to admin_community_paypal_account_path(@current_community.id)
    else
      flash[:error] = t("paypal_accounts.new.permissions_not_granted")
      redirect_to new_admin_community_paypal_account_path(@current_community.id)
    end
  end


  private

  def affirm_billing_agreement(token)
    affirm_billing_agreement_req = PaypalService::DataTypes::Merchant
      .create_create_billing_agreement({token: token})

    paypal_merchant.do_request(affirm_billing_agreement_req)
  end

  def fetch_access_token(request_token, verification_code)
    access_token_req = DataTypePermissions.create_get_access_token(
      {
        request_token: params[:request_token],
        verification_code: params[:verification_code]
      }
    )
    access_token_res = paypal_permissions.do_request(access_token_req)
  end

  def fetch_personal_data(token, token_secret)
    personal_data_req = DataTypePermissions.create_get_basic_personal_data(
      {
        token: token,
        token_secret: token_secret
      }
    )
    paypal_permissions.do_request(personal_data_req)
  end


  def flash_error_and_redirect_to_settings(error = t("paypal_accounts.new.something_went_wrong"))
    flash[:error] = error
    redirect_to new_paypal_account_settings_payment_path(@current_user.username)
  end
end
