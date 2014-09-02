class Admin::PaypalAccountsController < ApplicationController
  before_filter :ensure_is_admin
  before_filter :ensure_paypal_enabled

  skip_filter :dashboard_only

  def show
    paypal_account = find_paypal_account

    if paypal_account
      render locals: {paypal_account: paypal_account }
    else
      redirect_to action: :new
    end
  end

  def new
    render locals: {paypal_account: build_paypal_account({}) }
  end

  def create
    paypal_account = build_paypal_account(params[:paypal_account])
    successful = paypal_account.save

    do_redirect(successful, paypal_account)
  end

  private

  def do_redirect(successful, paypal_account)
    if successful
      flash[:message] = t(".successfully_saved")
      redirect_to action: :show
    else
      flash[:error] = paypal_account.errors.full_messages.join(", ")
      render :new, locals: {paypal_account: paypal_account }
    end
  end

  def find_paypal_account
    @current_community.paypal_account
  end

  def build_paypal_account(paypal_params)
    @current_community.build_paypal_account(paypal_params)
  end

  # Before filter
  def ensure_paypal_enabled
    unless @current_community.paypal_enabled?
      flash[:error] = "Paypal is not enabled for this community"
      redirect_to edit_details_admin_community_path(@current_community)
    end
  end
end
