class PaypalAccountForm
  extend ActiveModel::Naming
  include ActiveModel::Validations
  include ActiveModel::Conversion

  attr_reader :paypal_email
  validates_presence_of :paypal_email

  def initialize(opts = {})
    @paypal_email = opts[:paypal_email]
  end

  def persisted?
    false
  end
end

class PaypalAccountsController < ApplicationController

  before_filter do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_view_your_settings")
  end

  skip_filter :dashboard_only

  def show
    paypal_account = MarketplaceService::PaypalAccount::Query.personal_account(@current_user.id, @current_community.id)

    if paypal_account
      @selected_left_navi_link = "payments"

      render(locals: {
        left_hand_navigation_links: settings_links_for(@current_user, @current_community),
        paypal_account: paypal_account})
    else
      redirect_to :action => "new"
    end
  end

  def new
    @selected_left_navi_link = "payments"

    render(locals: {
        left_hand_navigation_links: settings_links_for(@current_user, @current_community),
        form_action: person_paypal_accounts_path(@current_user),
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
end
