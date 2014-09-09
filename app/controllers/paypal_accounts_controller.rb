class PaypalAccountsController < ApplicationController

  before_filter do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_view_your_settings")
  end

  before_filter :ensure_paypal_enabled

  skip_filter :dashboard_only

  PaypalAccountForm = FormUtils.define_form("PaypalAccountForm", :paypal_email)
    .with_validations { validates_presence_of :paypal_email }

  def show
    paypal_account = MarketplaceService::PaypalAccount::Query.personal_account(@current_user.id, @current_community.id)
    return redirect_to action: :new unless paypal_account

    @selected_left_navi_link = "payments"

    render(locals: {
      left_hand_navigation_links: settings_links_for(@current_user, @current_community),
      paypal_account: paypal_account})
  end

  def new
    paypal_account = MarketplaceService::PaypalAccount::Query.personal_account(@current_user.id, @current_community.id)
    return redirect_to action: :show if paypal_account

    @selected_left_navi_link = "payments"

    render(locals: {
        left_hand_navigation_links: settings_links_for(@current_user, @current_community),
        form_action: person_paypal_account_path(@current_user),
        paypal_account_form: PaypalAccountForm.new })
  end

  def create
    paypal_account_form = PaypalAccountForm.new(params[:paypal_account_form])

    if paypal_account_form.valid?
      MarketplaceService::PaypalAccount::Command.create_personal_account(
        @current_user.id,
        @current_community.id,
        { email: paypal_account_form.paypal_email })

      redirect_to :action => "show"
    else
      flash[:error] = paypal_account_form.errors.full_messages
      render(:new, locals: {
        left_hand_navigation_links: settings_links_for(@current_user, @current_community),
        form_action: person_paypal_accounts_path(@current_user),
        paypal_account_form: paypal_account_form })
    end
  end


  private

  # Before filter
  def ensure_paypal_enabled
    unless @current_community.paypal_enabled?
      flash[:error] = "Paypal is not enabled for this community"
      redirect_to person_settings_path(@current_user)
    end
  end
end
