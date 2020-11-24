class Admin::PaypalPreferencesController < Admin::AdminBaseController

  before_action :ensure_paypal_provisioned

  def index
    redirect_to admin_payment_preferences_path
  end

  def account_create
    community_country_code = LocalizationUtils.valid_country_code(@current_community.country)
    response = accounts_api.request(
      body: PaypalService::API::DataTypes.create_create_account_request(
      {
        community_id: @current_community.id,
        callback_url: admin_paypal_preferences_permissions_verified_url,
        country: community_country_code
      }))
    permissions_url = response.data[:redirect_url]

    if permissions_url.blank?
      flash[:error] = t("paypal_accounts.new.could_not_fetch_redirect_url")
      return redirect_to admin_payment_preferences_path
    else
      render json: {redirect_url: permissions_url}
    end
  end

  def permissions_verified
    unless params[:verification_code].present?
      flash[:error] = t("paypal_accounts.new.permissions_not_granted")
      return redirect_to admin_payment_preferences_path
    end

    response = accounts_api.create(
      community_id: @current_community.id,
      order_permission_request_token: params[:request_token],
      body: PaypalService::API::DataTypes
        .create_account_permission_verification_request(
          {
            order_permission_verification_code: params[:verification_code]
          }))

    if response[:success]
      redirect_to admin_payment_preferences_path
    else
      flash_error_and_redirect_to_settings(error_response: response)
    end
  end

  private

  # Before filter
  def ensure_paypal_provisioned
    unless PaypalHelper.paypal_provisioned?(@current_community.id)
      flash[:error] = t("paypal_accounts.new.paypal_not_enabled")
      redirect_to admin_details_edit_path
    end
  end

  def flash_error_and_redirect_to_settings(error_response: nil)
    error =
      if (error_response && error_response[:error_code] == "570058")
        t("paypal_accounts.new.account_not_verified")
      elsif (error_response && error_response[:error_code] == "520009")
        t("paypal_accounts.new.account_restricted")
      else
        t("paypal_accounts.new.something_went_wrong")
      end

    flash[:error] = error
    redirect_to admin_payment_preferences_path
  end

  def paypal_minimum_commissions_api
    PaypalService::API::Api.minimum_commissions
  end

  def tx_settings_api
    TransactionService::API::Api.settings
  end

  def accounts_api
    PaypalService::API::Api.accounts
  end

end
