class PaypalAccountsController < ApplicationController
  include PaypalService::PermissionsInjector
  include PaypalService::MerchantInjector

  PaypalAccountEntity = MarketplaceService::PaypalAccount::Entity
  PaypalAccountQuery = MarketplaceService::PaypalAccount::Query
  PaypalAccountCommand = MarketplaceService::PaypalAccount::Command

  before_filter do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_view_your_settings")
  end

  before_filter :ensure_paypal_enabled

  skip_filter :dashboard_only

  PaypalAccountForm = FormUtils.define_form("PaypalAccountForm")

  def show
    paypal_account = PaypalAccountQuery.personal_account(@current_user.id, @current_community.id)
    return redirect_to action: :new unless PaypalAccountEntity.paypal_account_prepared?(paypal_account)

    @selected_left_navi_link = "payments"
    commission_from_seller = @current_community.commission_from_seller ? @current_community.commission_from_seller : 0

    render(locals: {
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

    render(locals: {
      left_hand_navigation_links: settings_links_for(@current_user, @current_community),
      form_action: person_paypal_account_path(@current_user),
      paypal_account_form: PaypalAccountForm.new,
      paypal_account_state: Maybe(paypal_account)[:order_permission_state].or_else(""),
      paypal_account_email: Maybe(paypal_account)[:email].or_else(""),
      commission_from_seller: t("paypal_accounts.commission", commission: commission_from_seller)
    })
  end

  def create
    paypal_account = PaypalAccountQuery.personal_account(@current_user.id, @current_community.id)
    order_permission_verified = PaypalAccountEntity.order_permission_verified?(paypal_account)

    if order_permission_verified
      create_billing_agreement
    else
      create_paypal_account
    end
  end


  private

  def create_paypal_account
    paypal_account_form = PaypalAccountForm.new(params[:paypal_account_form])

    if paypal_account_form.valid?
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

    else
      flash[:error] = paypal_account_form.errors.full_messages
      render(:new, locals: {
        left_hand_navigation_links: settings_links_for(@current_user, @current_community),
        form_action: person_paypal_account_path(@current_user),
        paypal_account_form: paypal_account_form })
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
      .create_req_perm({callback: paypal_permissions_hook_url })

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
        success: paypal_billing_agreement_success_hook_url,
        cancel: paypal_billing_agreement_cancel_hook_url
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

end
