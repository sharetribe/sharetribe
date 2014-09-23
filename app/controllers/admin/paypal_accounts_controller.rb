class Admin::PaypalAccountsController < ApplicationController
  before_filter :ensure_is_admin
  before_filter :ensure_paypal_enabled

  skip_filter :dashboard_only

  PaypalAccountEntity = MarketplaceService::PaypalAccount::Entity
  PaypalAccountQuery = MarketplaceService::PaypalAccount::Query
  PaypalAccountForm = FormUtils.define_form("PaypalAccountForm", :paypal_email, :commission_from_seller)
    .with_validations { validates_presence_of :paypal_email }


  def show
    paypal_account = PaypalAccountQuery.admin_account(@current_community.id)
    return redirect_to action: :new unless PaypalAccountEntity.order_permission_verified?(paypal_account)

    @selected_left_navi_link = "paypal_account"

    render locals: {
      paypal_account_email: Maybe(paypal_account)[:email].or_else("")
    }
  end

  def new
    paypal_account = PaypalAccountQuery.admin_account(@current_community.id)
    return redirect_to action: :show if PaypalAccountEntity.order_permission_verified?(paypal_account)

    @selected_left_navi_link = "paypal_account"

    render(locals: {
      form_action: admin_community_paypal_account_path(@current_community),
      paypal_account_form: PaypalAccountForm.new
    })
  end

  def create
    paypal_account_form = build_paypal_account_form(params[:paypal_account_form])

    if paypal_account_form.valid?
      MarketplaceService::PaypalAccount::Command.create_admin_account(
        @current_community.id,
        {
          email: paypal_account_form.email,
          api_password: paypal_account_form.api_password,
          api_signature: paypal_account_form.api_signature
        }
      )
      redirect_to action: :show
    else
      flash[:error] = paypal_account_form.errors.full_messages.join(", ")
      render :new, locals: {paypal_account: paypal_account_form }
    end
  end

  private

  def build_paypal_account_form(paypal_params = {})
    PaypalAccountForm.new(paypal_params)
  end

  # Before filter
  def ensure_paypal_enabled
    unless @current_community.paypal_enabled?
      flash[:error] = "Paypal is not enabled for this community"
      redirect_to edit_details_admin_community_path(@current_community)
    end
  end
end
