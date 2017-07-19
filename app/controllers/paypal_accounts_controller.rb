class PaypalAccountsController < ApplicationController
  before_action do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_view_your_settings")
  end

  before_action :ensure_paypal_enabled

  DataTypePermissions = PaypalService::DataTypes::Permissions

  def index
    redirect_to person_payment_settings_path(@current_user) 
  end

  def ask_order_permission
    return redirect_to person_payment_settings_path(@current_user) unless PaypalHelper.community_ready_for_payments?(@current_community)

    community_country_code = LocalizationUtils.valid_country_code(@current_community.country)
    response = accounts_api.request(
      body: PaypalService::API::DataTypes.create_create_account_request(
      {
        community_id: @current_community.id,
        person_id: @current_user.id,
        callback_url: permissions_verified_person_paypal_account_url,
        country: community_country_code
      }),
      flow: :old)

    permissions_url = response.data[:redirect_url]

    if permissions_url.blank?
      flash[:error] = t("paypal_accounts.new.could_not_fetch_redirect_url")
      return redirect_to person_payment_settings_path(@current_user
    else
      render json: {redirect_url: permissions_url}
    end
  end

  def ask_billing_agreement
    return redirect_to person_payment_settings_path(@current_user) unless PaypalHelper.community_ready_for_payments?(@current_community)

    account_response = accounts_api.get(
      community_id: @current_community.id,
      person_id: @current_user.id
    )
    m_account = account_response.maybe

    case m_account[:order_permission_state]
    when Some(:verified)

      response = accounts_api.billing_agreement_request(
        community_id: @current_community.id,
        person_id: @current_user.id,
        body: PaypalService::API::DataTypes.create_create_billing_agreement_request(
          {
            description: t("paypal_accounts.new.billing_agreement_description"),
            success_url:  billing_agreement_success_person_paypal_account_url,
            cancel_url:   billing_agreement_cancel_person_paypal_account_url
          }
        ))

      billing_agreement_url = response.data[:redirect_url]

      if billing_agreement_url.blank?
        flash[:error] = t("paypal_accounts.new.could_not_fetch_redirect_url")
        return redirect_to person_payment_settings_path(@current_user) 
      else
        render json: {redirect_url: billing_agreement_url}
      end

    else
      redirect_to action: ask_order_permission
    end
  end

  def permissions_verified

    unless params[:verification_code].present?
      return flash_error_and_redirect_to_settings(error_msg: t("paypal_accounts.new.permissions_not_granted"))
    end

    response = accounts_api.create(
      community_id: @current_community.id,
      person_id: @current_user.id,
      order_permission_request_token: params[:request_token],
      body: PaypalService::API::DataTypes.create_account_permission_verification_request(
        {
          order_permission_verification_code: params[:verification_code]
        }
      ),
      flow: :old)

    if response[:success]
      redirect_to paypal_account_settings_payment_path(@current_user.username)
    else
      flash_error_and_redirect_to_settings(error_response: response) unless response[:success]
    end
  end

  def billing_agreement_success
    response = accounts_api.billing_agreement_create(
      community_id: @current_community.id,
      person_id: @current_user.id,
      billing_agreement_request_token: params[:token]
    )

    if response[:success]
      redirect_to paypal_account_settings_payment_path(@current_user.username)
    else
      case response.error_msg
      when :billing_agreement_not_accepted
        flash_error_and_redirect_to_settings(error_msg: t("paypal_accounts.new.billing_agreement_not_accepted"))
      when :wrong_account
        flash_error_and_redirect_to_settings(error_msg: t("paypal_accounts.new.billing_agreement_wrong_account"))
      else
        flash_error_and_redirect_to_settings(error_response: response)
      end
    end
  end

  def billing_agreement_cancel
    accounts_api.delete_billing_agreement(
      community_id: @current_community.id,
      person_id: @current_user.id
    )

    flash[:error] = t("paypal_accounts.new.billing_agreement_canceled")
    redirect_to paypal_account_settings_payment_path(@current_user.username)
  end


  private

  def next_action(paypal_account_state)
    if paypal_account_state == :verified
      :none
    elsif paypal_account_state == :connected
      :ask_billing_agreement
    else
      :ask_order_permission
    end
  end

  # Before filter
  def ensure_paypal_enabled
    unless PaypalHelper.paypal_active?(@current_community.id)
      flash[:error] = t("paypal_accounts.new.paypal_not_enabled")
      redirect_to person_settings_path(@current_user)
    end
  end

  def flash_error_and_redirect_to_settings(error_response: nil, error_msg: nil)
    error_msg =
      if (error_msg)
        error_msg
      elsif (error_response && error_response[:error_code] == "570058")
        t("paypal_accounts.new.account_not_verified")
      elsif (error_response && error_response[:error_code] == "520009")
        t("paypal_accounts.new.account_restricted")
      else
        t("paypal_accounts.new.something_went_wrong")
      end

    flash[:error] = error_msg
    redirect_to person_payment_settings_path(@current_user) 
  end

  def payment_gateway_commission(community_id)
    p_set =
      Maybe(payment_settings_api.get_active_by_gateway(community_id: community_id, payment_gateway: :paypal))
      .map {|res| res[:success] ? res[:data] : nil}
      .select {|set| set[:payment_gateway] == :paypal }
      .or_else(nil)

    raise ArgumentError.new("No active paypal gateway for community: #{community_id}.") if p_set.nil?

    p_set[:commission_from_seller]
  end

  def payment_settings_api
    TransactionService::API::Api.settings
  end

  def accounts_api
    PaypalService::API::Api.accounts
  end

end
