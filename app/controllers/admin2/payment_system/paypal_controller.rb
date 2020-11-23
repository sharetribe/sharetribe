module Admin2::PaymentSystem
  class PaypalController < Admin2::AdminBaseController

    include Payments

    before_action :ensure_payments_enabled
    before_action :ensure_params_payment_gateway, only: %i[enable disable]

    def index
      payment_index
    end

    def paypal_index
      paypal_account = paypal_accounts_api.get(community_id: @current_community.id).data
      { order_permission_action: account_create_admin2_payment_system_paypal_index_path,
        paypal_account: paypal_account }
    end

    def common_update
      message = update_payment_preferences

      render json: { message: message }
    rescue StandardError => e
      render json: { message: e.message }, status: :unprocessable_entity
    end

    def account_create
      community_country_code = LocalizationUtils.valid_country_code(@current_community.country)
      response = paypal_accounts_api.request(
        body: PaypalService::API::DataTypes.create_create_account_request(
          { community_id: @current_community.id,
            callback_url: permissions_verified_admin2_payment_system_paypal_index_url,
            country: community_country_code }))
      permissions_url = response.data[:redirect_url]
      if permissions_url.blank?
        flash[:error] = t("paypal_accounts.new.could_not_fetch_redirect_url")
        redirect_to admin2_payment_system_paypal_index_path
      else
        render json: { redirect_url: permissions_url }
      end
    end

    def permissions_verified
      unless params[:verification_code].present?
        flash[:error] = t("paypal_accounts.new.permissions_not_granted")
        return redirect_to admin2_payment_system_paypal_index_path
      end
      response = paypal_accounts_api.create(
        community_id: @current_community.id,
        order_permission_request_token: params[:request_token],
        body: PaypalService::API::DataTypes.create_account_permission_verification_request(
                  { order_permission_verification_code: params[:verification_code] }))

      if response[:success]
        redirect_to admin2_payment_system_paypal_index_path
      else
        flash_error_and_redirect_to_settings(error_response: response)
      end
    end

    def flash_error_and_redirect_to_settings(error_response: nil)
      error = if error_response && error_response[:error_code] == '570058'
                t("paypal_accounts.new.account_not_verified")
              elsif error_response && error_response[:error_code] == '520009'
                t("paypal_accounts.new.account_restricted")
              else
                t("paypal_accounts.new.something_went_wrong")
              end
      flash[:error] = error
      redirect_to admin2_payment_system_paypal_index_path
    end
  end
end
