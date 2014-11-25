class PaypalAccountsController < ApplicationController
  include PaypalService::PermissionsInjector
  include PaypalService::MerchantInjector

  before_filter do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_view_your_settings")
  end

  before_filter :ensure_paypal_enabled

  skip_filter :dashboard_only

  PaypalAccountForm = FormUtils.define_form("PaypalAccountForm")
  PaypalAccountEntity = PaypalService::PaypalAccount::Entity
  PaypalAccountQuery = PaypalService::PaypalAccount::Query
  PaypalAccountCommand = PaypalService::PaypalAccount::Command

  DataTypePermissions = PaypalService::DataTypes::Permissions

  def show
    paypal_account = PaypalAccountQuery.personal_account(@current_user.id, @current_community.id)
    return redirect_to action: :new unless PaypalAccountEntity.paypal_account_prepared?(paypal_account)

    @selected_left_navi_link = "payments"
    commission_from_seller = @current_community.commission_from_seller ? @current_community.commission_from_seller : 0

    community_ready_for_payments = PaypalHelper.community_ready_for_payments?(@current_community)
    flash.now[:error] = t("paypal_accounts.new.admin_account_not_connected") unless community_ready_for_payments

    render(locals: {
      community_ready_for_payments: community_ready_for_payments,
      left_hand_navigation_links: settings_links_for(@current_user, @current_community),
      paypal_account: paypal_account,
      paypal_account_email: Maybe(paypal_account)[:email].or_else(""),
      commission_from_seller: t("paypal_accounts.commission", commission: commission_from_seller)
    })
  end

  def new
    paypal_account = PaypalAccountQuery.personal_account(@current_user.id, @current_community.id)
    return redirect_to action: :show if PaypalAccountEntity.paypal_account_prepared?(paypal_account)

    @selected_left_navi_link = "payments"
    commission_from_seller = @current_community.commission_from_seller ? @current_community.commission_from_seller : 0
    community_currency = @current_community.default_currency

    community_ready_for_payments = PaypalHelper.community_ready_for_payments?(@current_community)
    flash.now[:error] = t("paypal_accounts.new.admin_account_not_connected") unless community_ready_for_payments

    render(locals: {
      community_ready_for_payments: community_ready_for_payments,
      left_hand_navigation_links: settings_links_for(@current_user, @current_community),
      form_action: person_paypal_account_path(@current_user),
      paypal_account_form: PaypalAccountForm.new,
      paypal_account_state: Maybe(paypal_account)[:order_permission_state].or_else(""),
      paypal_account_email: Maybe(paypal_account)[:email].or_else(""),
      commission_from_seller: t("paypal_accounts.commission", commission: commission_from_seller),
      minimum_commission: minimum_commission,
      currency: community_currency
    })
  end

  def create
    return redirect_to action: :new unless PaypalHelper.community_ready_for_payments?(@current_community)

    paypal_account = PaypalAccountQuery.personal_account(@current_user.id, @current_community.id)
    order_permission_verified = PaypalAccountEntity.order_permission_verified?(paypal_account)

    if order_permission_verified
      create_billing_agreement
    else
      create_paypal_account
    end
  end

  def permissions_verified

    unless params[:verification_code].present?
      return flash_error_and_redirect_to_settings(error_msg: t("paypal_accounts.new.permissions_not_granted"))
    end

    access_token_res = fetch_access_token(params[:request_token], params[:verification_code])
    return flash_error_and_redirect_to_settings(error_response: access_token_res) unless access_token_res[:success]

    personal_data_res = fetch_personal_data(access_token_res[:token], access_token_res[:token_secret])
    return flash_error_and_redirect_to_settings(error_response: personal_data_res) unless personal_data_res[:success]

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

  def billing_agreement_success
    affirm_agreement_res = affirm_billing_agreement(params[:token])
    return flash_error_and_redirect_to_settings(error_response: affirm_agreement_res) unless affirm_agreement_res[:success]

    billing_agreement_id = affirm_agreement_res[:billing_agreement_id]

    express_checkout_details_req = PaypalService::DataTypes::Merchant.create_get_express_checkout_details({token: params[:token]})
    express_checkout_details_res = paypal_merchant.do_request(express_checkout_details_req)

    paypal_account =  PaypalAccountQuery.personal_account(@current_user.id, @current_community.id)
    if !express_checkout_details_res[:billing_agreement_accepted] ||
      express_checkout_details_res[:payer_id] != paypal_account[:payer_id]

      return flash_error_and_redirect_to_settings(error_msg: t("paypal_accounts.new.billing_agreement_not_accepted"))
    end

    success = PaypalAccountCommand.confirm_billing_agreement(@current_user.id, @current_community.id, params[:token], billing_agreement_id)
    redirect_to show_paypal_account_settings_payment_path(@current_user.username)
  end

  def billing_agreement_cancel
    PaypalAccountCommand.cancel_pending_billing_agreement(@current_user.id, @current_community.id, params[:token])

    flash[:error] = t("paypal_accounts.new.billing_agreement_canceled")
    redirect_to new_paypal_account_settings_payment_path(@current_user.username)
  end


  private

  def create_paypal_account
    PaypalAccountCommand.create_personal_account(
      @current_user.id,
      @current_community.id
    )

    permissions_url = request_paypal_permissions_url

    if permissions_url.blank?
      flash[:error] = t("paypal_accounts.new.could_not_fetch_redirect_url")
      return redirect_to action: :new
    else
      return redirect_to permissions_url
    end
  end

  def create_billing_agreement
    billing_agreement_url = request_paypal_billing_agreement_url

    if billing_agreement_url.blank?
      flash[:error] = t("paypal_accounts.new.could_not_fetch_redirect_url")
      return redirect_to action: :new
    else
      return redirect_to billing_agreement_url
    end

  end


  # Before filter
  def ensure_paypal_enabled
    unless @current_community.paypal_enabled?
      flash[:error] = t("paypal_accounts.new.paypal_not_enabled")
      redirect_to person_settings_path(@current_user)
    end
  end

  def request_paypal_permissions_url
    permission_request = PaypalService::DataTypes::Permissions
      .create_req_perm({callback: permissions_verified_person_paypal_account_url })

    response = paypal_permissions.do_request(permission_request)
    if response[:success]
      PaypalAccountCommand.create_pending_permissions_request(
          @current_user.id,
          @current_community.id,
          response[:username_to],
          permission_request[:scope],
          response[:request_token]
        )
      response[:redirect_url]
    else
      nil
    end
  end

  def request_paypal_billing_agreement_url
    commission_from_seller = @current_community.commission_from_seller ? "#{@current_community.commission_from_seller} %" : "0 %"
    billing_agreement_request = PaypalService::DataTypes::Merchant
      .create_setup_billing_agreement({
        description: t("paypal_accounts.new.billing_agreement_description"),
        success:  billing_agreement_success_person_paypal_account_url,
        cancel:   billing_agreement_cancel_person_paypal_account_url
      })

    response = paypal_merchant.do_request(billing_agreement_request)
    if response[:success]
      PaypalAccountCommand.create_pending_billing_agreement(
          @current_user.id,
          @current_community.id,
          response[:username_to],
          response[:token]
        )
      response[:redirect_url]
    else
      nil
    end
  end

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

  def flash_error_and_redirect_to_settings(error_response: nil, error_msg: nil)
    error_msg =
      if (error_msg)
        error_msg
      elsif (error_response && error_response[:error_code] == "570058")
        t("paypal_accounts.new.account_not_verified")
      else
        t("paypal_accounts.new.something_went_wrong")
      end

    flash[:error] = error_msg
    redirect_to new_paypal_account_settings_payment_path(@current_user.username)
  end

  def minimum_commission
    payment_type = MarketplaceService::Community::Query.payment_type(@current_community.id)
    currency = @current_community.default_currency

    case payment_type
    when :paypal
      paypal_minimum_commissions_api.get(currency)
    else
      Money.new(0, currency)
    end
  end

  def paypal_minimum_commissions_api
    PaypalService::API::Api.minimum_commissions_api
  end

end
