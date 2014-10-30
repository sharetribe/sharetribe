class Admin::PaypalAccountsController < ApplicationController
  include PaypalService::PermissionsInjector

  before_filter :ensure_is_admin
  before_filter :ensure_paypal_enabled

  skip_filter :dashboard_only

  PaypalAccountEntity = PaypalService::PaypalAccount::Entity
  PaypalAccountQuery = PaypalService::PaypalAccount::Query
  PaypalAccountCommand = PaypalService::PaypalAccount::Command
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
    community_currency = @current_community.default_currency

    render(locals: {
      form_action: admin_community_paypal_account_path(@current_community),
      paypal_account_form: PaypalAccountForm.new,
      currency: community_currency
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

  def permissions_verified
    unless params[:verification_code].present?
      flash[:error] = t("paypal_accounts.new.permissions_not_granted")
      return redirect_to new_admin_community_paypal_account_path(@current_community.id)
    end

    access_token_res = fetch_access_token(params[:request_token], params[:verification_code])
    return flash_error_and_redirect_to_settings unless access_token_res[:success]

    personal_data_res = fetch_personal_data(access_token_res[:token], access_token_res[:token_secret])
    return flash_error_and_redirect_to_settings unless personal_data_res[:success]

    PaypalAccountCommand.update_admin_account(
      @current_community.id,
      {
        email: personal_data_res[:email],
        payer_id: personal_data_res[:payer_id]
      }
    )
    PaypalAccountCommand.confirm_pending_permissions_request(
      nil,
      @current_community.id,
      params[:request_token],
      access_token_res[:scope].join(","),
      params[:verification_code]
    )

    redirect_to admin_community_paypal_account_path(@current_community.id)
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
      .create_req_perm({callback: permissions_verified_admin_community_paypal_account_url })

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

  # TODO This is copy-paste
  def fetch_access_token(request_token, verification_code)
    access_token_req = PaypalService::DataTypes::Permissions.create_get_access_token(
      {
        request_token: params[:request_token],
        verification_code: params[:verification_code]
      }
    )
    access_token_res = paypal_permissions.do_request(access_token_req)
  end

  # TODO This is copy-paste
  def fetch_personal_data(token, token_secret)
    personal_data_req = PaypalService::DataTypes::Permissions.create_get_basic_personal_data(
      {
        token: token,
        token_secret: token_secret
      }
    )
    paypal_permissions.do_request(personal_data_req)
  end

  def flash_error_and_redirect_to_settings(error = t("paypal_accounts.new.something_went_wrong"))
    flash[:error] = error
    redirect_to new_admin_community_paypal_account_path(@current_user.username)
  end

end
