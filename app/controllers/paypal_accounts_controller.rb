class PaypalAccountsController < ApplicationController

  before_filter do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_view_your_settings")
  end

  skip_filter :dashboard_only

  def show
    paypal_account = PaypalAccount.where(person_id: @current_user.id).first

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
        paypal_account: PaypalAccount.new})
  end

  def create
    paypal_account = PaypalAccount.new(
      params[:paypal_account].merge({person: @current_user , community: @current_community }))

    if paypal_account.valid?
      paypal_account.save!
      redirect_to :action => "show"
    else
      flash[:error] = paypal_account.errors.full_messages
      render(:new, locals: {
        left_hand_navigation_links: settings_links_for(@current_user, @current_community),
        form_action: person_paypal_accounts_path(@current_user),
        paypal_account: paypal_account })
    end
  end
end
