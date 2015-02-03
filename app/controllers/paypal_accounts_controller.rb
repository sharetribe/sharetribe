class PaypalAccountsController < ApplicationController
  before_filter do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_view_your_settings")
  end

  before_filter :ensure_paypal_enabled

  PaypalAccountForm = FormUtils.define_form("PaypalAccountForm")

  DataTypePermissions = PaypalService::DataTypes::Permissions

  def show
    m_account = accounts_api.get(
      community_id: @current_community.id,
      person_id: @current_user.id
    ).maybe

    return redirect_to action: :new unless m_account[:state].or_else(:not_verified) == :verified

    @selected_left_navi_link = "payments"

    community_ready_for_payments = PaypalHelper.community_ready_for_payments?(@current_community)
    unless community_ready_for_payments
      flash.now[:warning] = t("paypal_accounts.new.admin_account_not_connected",
                            contact_admin_link: view_context.link_to(
                              t("paypal_accounts.new.contact_admin_link_text"),
                                new_user_feedback_path)).html_safe
    end

    render(locals: {
      community_ready_for_payments: community_ready_for_payments,
      left_hand_navigation_links: settings_links_for(@current_user, @current_community),
      paypal_account_email: m_account[:email].or_else(""),
      change_url: ask_order_permission_person_paypal_account_path(@current_user)
    })
  end

  def new
    m_account = accounts_api.get(
      community_id: @current_community.id,
      person_id: @current_user.id
    ).maybe

    return redirect_to action: :show if m_account[:state].or_else(:not_verified) == :verified

    @selected_left_navi_link = "payments"
    commission_from_seller = payment_gateway_commission(@current_community.id)
    community_currency = @current_community.default_currency

    community_ready_for_payments = PaypalHelper.community_ready_for_payments?(@current_community)
    unless community_ready_for_payments
      flash.now[:warning] = t("paypal_accounts.new.admin_account_not_connected",
                            contact_admin_link: view_context.link_to(
                              t("paypal_accounts.new.contact_admin_link_text"),
                                new_user_feedback_path)).html_safe
    end

    community_country_code = LocalizationUtils.valid_country_code(@current_community.country)

    render(locals: {
      community_ready_for_payments: community_ready_for_payments,
      left_hand_navigation_links: settings_links_for(@current_user, @current_community),
      order_permission_action: ask_order_permission_person_paypal_account_path(@current_user),
      billing_agreement_action: ask_billing_agreement_person_paypal_account_path(@current_user),
      paypal_account_form: PaypalAccountForm.new,
      paypal_account_state: m_account[:order_permission_state].or_else(""),
      paypal_account_email: m_account[:email].or_else(""),
      change_url: ask_order_permission_person_paypal_account_path(@current_user),
      commission_from_seller: t("paypal_accounts.commission", commission: commission_from_seller),
      minimum_commission: minimum_commission(),
      currency: community_currency,
      create_url: "https://www.paypal.com/#{community_country_code}/signup",
      upgrade_url: "https://www.paypal.com/#{community_country_code}/upgrade"
    })
  end

  def ask_order_permission
    return redirect_to action: :new unless PaypalHelper.community_ready_for_payments?(@current_community)

    community_country_code = LocalizationUtils.valid_country_code(@current_community.country)
    response = accounts_api.request(
      body: PaypalService::API::DataTypes.create_create_account_request(
      {
        community_id: @current_community.id,
        person_id: @current_user.id,
        callback_url: permissions_verified_person_paypal_account_url,
        country: community_country_code
      }))

    permissions_url = response.data[:redirect_url]

    if permissions_url.blank?
      flash[:error] = t("paypal_accounts.new.could_not_fetch_redirect_url")
      return redirect_to action: :new
    else
      return redirect_to permissions_url
    end
  end

  def ask_billing_agreement
    return redirect_to action: :new unless PaypalHelper.community_ready_for_payments?(@current_community)

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
        return redirect_to action: :new
      else
        return redirect_to billing_agreement_url
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
      ))

    if response[:success]
      redirect_to new_paypal_account_settings_payment_path(@current_user.username)
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
      redirect_to show_paypal_account_settings_payment_path(@current_user.username)
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
    redirect_to new_paypal_account_settings_payment_path(@current_user.username)
  end


  private

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

  def payment_gateway_commission(community_id)
    p_set =
      Maybe(payment_settings_api.get_active(community_id: community_id))
      .map {|res| res[:success] ? res[:data] : nil}
      .select {|set| set[:payment_gateway] == :paypal }
      .or_else(nil)

    raise ArgumentError.new("No active paypal gateway for community: #{community_id}.") if p_set.nil?

    p_set[:commission_from_seller]
  end

  def paypal_minimum_commissions_api
    PaypalService::API::Api.minimum_commissions
  end

  def payment_settings_api
    TransactionService::API::Api.settings
  end

  def accounts_api
    PaypalService::API::Api.accounts_api
  end

end
