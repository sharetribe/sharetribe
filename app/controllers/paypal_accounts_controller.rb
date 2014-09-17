class PaypalAccountsController < ApplicationController
  include PaypalService::PermissionsInjector

  before_filter do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_view_your_settings")
  end

  before_filter :ensure_paypal_enabled

  skip_filter :dashboard_only

  PaypalAccountForm = FormUtils.define_form("PaypalAccountForm", :paypal_email)
    .with_validations { validates_presence_of :paypal_email }

  def show
    billing_agreement = false #TODO link to actual model when ready
    paypal_account = MarketplaceService::PaypalAccount::Query.personal_account(@current_user.id, @current_community.id)

    account_entity = MarketplaceService::PaypalAccount::Entity
    return redirect_to action: :new if account_entity.verified_account?(paypal_account)
    return redirect_to action: :new if billing_agreement.blank?

    @selected_left_navi_link = "payments"

    render(locals: {
      left_hand_navigation_links: settings_links_for(@current_user, @current_community),
      paypal_account: paypal_account,
      commission_from_seller: @current_community.commission_from_seller
    })
  end

  def new
    billing_agreement = false #TODO link to actual model when ready
    paypal_account = MarketplaceService::PaypalAccount::Query.personal_account(@current_user.id, @current_community.id)

    is_verified = MarketplaceService::PaypalAccount::Entity.verified_account?(paypal_account)
    return redirect_to action: :show if billing_agreement.present? && is_verified

    @selected_left_navi_link = "payments"
    commission_from_seller = @current_community.commission_from_seller ? "#{@current_community.commission_from_seller} %" : "0 %"

    render(locals: {
      left_hand_navigation_links: settings_links_for(@current_user, @current_community),
      form_action: person_paypal_account_path(@current_user),
      paypal_account_form: PaypalAccountForm.new,
      billing_agreement: billing_agreement,
      paypal_account_state: Maybe(paypal_account)[:order_permission_state].or_else(""),
      paypal_account_email: Maybe(paypal_account)[:email].or_else(""),
      commission_from_seller: commission_from_seller
    })
  end

  def create
    paypal_account_form = PaypalAccountForm.new(params[:paypal_account_form])

    if paypal_account_form.valid?
      MarketplaceService::PaypalAccount::Command.create_personal_account(
        @current_user.id,
        @current_community.id,
        { email: paypal_account_form.paypal_email}
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


  private

  # Before filter
  def ensure_paypal_enabled
    unless @current_community.paypal_enabled?
      flash[:error] = t("paypal_accounts.new.paypal_not_enabled")
      redirect_to person_settings_path(@current_user)
    end
  end

  def request_paypal_permissions_url
    permission_request = PaypalService::DataTypes::Permissions
      .create_req_perm(paypal_permissions_hook_url)

    response = paypal_permissions.do_request(permission_request)
    if response[:success]
      MarketplaceService::PaypalAccount::Command
        .create_pending_permissions_request(
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


end
