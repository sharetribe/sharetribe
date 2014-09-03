class Admin::PaypalAccountForm
  extend ActiveModel::Naming
  include ActiveModel::Validations
  include ActiveModel::Conversion

  attr_reader(
    :email,
    :api_password,
    :api_signature
  )

  validates_presence_of :email, :api_password, :api_signature

  def initialize(opts = {})
    @email = opts[:email]
    @api_password = opts[:api_password]
    @api_signature = opts[:api_signature]
  end

  def persisted?
    false
  end
end

class Admin::PaypalAccountsController < ApplicationController
  before_filter :ensure_is_admin
  before_filter :ensure_paypal_enabled

  skip_filter :dashboard_only

  def show
    paypal_account = MarketplaceService::PaypalAccount::Query.admin_account(@current_community.id)

    if paypal_account
      render locals: {paypal_account: paypal_account }
    else
      redirect_to action: :new
    end
  end

  def new
    render locals: {paypal_account: build_paypal_account_form }
  end

  def create
    paypal_account_form = build_paypal_account_form(params[:admin_paypal_account_form])

    if paypal_account_form.valid?
      result = MarketplaceService::PaypalAccount::Command.create_admin_account(
        @current_community.id,
        {
          email: paypal_account_form.email,
          api_password: paypal_account_form.api_password,
          api_signature: paypal_account_form.api_signature
        }
      )

      if result[:success]
        flash[:message] = t(".successfully_saved")
        redirect_to action: :show
      else
        flash[:error] = result.error_msg # TODO Should return symbol and translate it
        render :new, locals: {paypal_account: paypal_account_form }
      end

    else
      flash[:error] = paypal_account_form.errors.full_messages.join(", ")
      render :new, locals: {paypal_account: paypal_account_form }
    end
  end

  private

  def build_paypal_account_form(paypal_params = {})
    Admin::PaypalAccountForm.new(paypal_params)
  end

  # Before filter
  def ensure_paypal_enabled
    unless @current_community.paypal_enabled?
      flash[:error] = "Paypal is not enabled for this community"
      redirect_to edit_details_admin_community_path(@current_community)
    end
  end
end
