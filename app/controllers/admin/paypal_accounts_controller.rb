class Admin::PaypalAccountsController < ApplicationController
  include PaypalService::PermissionsInjector

  before_filter :ensure_is_admin
  before_filter :ensure_paypal_enabled

  skip_filter :dashboard_only

  PaypalAccountEntity = MarketplaceService::PaypalAccount::Entity
  PaypalAccountQuery = MarketplaceService::PaypalAccount::Query
  PaypalAccountCommand = MarketplaceService::PaypalAccount::Command
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
    PaypalAccountCommand.create_admin_account(@current_community.id)

    permissions_url = request_paypal_permissions_url

    if permissions_url.blank?
      flash[:error] = t("paypal_accounts.new.could_not_fetch_redirect_url")
      return redirect_to action: :new
    else
      return redirect_to permissions_url
    end

  end

  private

  # Before filter
  def ensure_paypal_enabled
    unless @current_community.paypal_enabled?
      flash[:error] = t("paypal_accounts.new.paypal_not_enabled")
      redirect_to edit_details_admin_community_path(@current_community)
    end
  end

  def request_paypal_permissions_url
    permission_request = PaypalService::DataTypes::Permissions
      .create_req_perm({callback: admin_paypal_permissions_hook_url })

    response = paypal_permissions.do_request(permission_request)
    if response[:success]
      PaypalAccountCommand.create_pending_permissions_request(
          nil,
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
