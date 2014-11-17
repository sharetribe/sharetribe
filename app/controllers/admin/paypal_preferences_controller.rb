class Admin::PaypalPreferencesController < ApplicationController
  include PaypalService::PermissionsInjector

  before_filter :ensure_is_admin
  before_filter :ensure_paypal_enabled

  skip_filter :dashboard_only

  PaypalAccountEntity = PaypalService::PaypalAccount::Entity
  PaypalAccountQuery = PaypalService::PaypalAccount::Query
  PaypalAccountCommand = PaypalService::PaypalAccount::Command
  PaypalAccountForm = FormUtils.define_form("PaypalAccountForm", :paypal_email, :commission_from_seller)
    .with_validations { validates_presence_of :paypal_email }

  MIN_COMMISSION_PERCENTAGE = 5
  MAX_COMMISSION_PERCENTAGE = 100

  PaypalPreferencesForm = FormUtils.define_form("PaypalPreferencesForm",
    :commission_from_seller,
    :minimum_listing_price,
    :minimum_commission
    ).with_validations do
      validates_numericality_of(
        :commission_from_seller,
        only_integer: true,
        allow_nil: false,
        greater_than_or_equal_to: MIN_COMMISSION_PERCENTAGE,
        less_than_or_equal_to: MAX_COMMISSION_PERCENTAGE)

      validate do |prefs|
        if minimum_listing_price.nil? || minimum_listing_price < minimum_commission
          prefs.errors[:minimum_listing_price] << "Minimum listing price has to be greater than minimum commission #{minimum_commission}"
        end
      end
    end

  def index
    @selected_left_navi_link = "paypal_account"
    paypal_account = PaypalAccountQuery.admin_account(@current_community.id)
    currency = @current_community.default_currency
    minimum_commission = paypal_minimum_commissions_api.get(currency)

    paypal_prefs_form = PaypalPreferencesForm.new(
      minimum_commission: minimum_commission,
      commission_from_seller: @current_community.commission_from_seller,
      minimum_listing_price: @current_community.minimum_price)

    render("index", locals: {
        paypal_account_email: Maybe(paypal_account)[:email].or_else(nil),
        paypal_form_action: account_create_admin_community_paypal_preferences_path(@current_community.id),
        paypal_account_form: PaypalAccountForm.new,
        paypal_prefs_valid: paypal_prefs_form.valid?,
        paypal_prefs_form: paypal_prefs_form,
        paypal_prefs_form_action: preferences_update_admin_community_paypal_preferences_path(@current_community.id),
        min_commission: minimum_commission,
        min_commission_percentage: 5,
        max_commission_percentage: 100,
        currency: currency
      })
  end

  def preferences_update
    currency = @current_community.default_currency
    minimum_commission = paypal_minimum_commissions_api.get(currency)

    paypal_prefs_form = PaypalPreferencesForm.new(
      parse_preferences(params[:paypal_preferences_form], currency).merge(minimum_commission: minimum_commission))

    unless paypal_prefs_form.valid?
      flash[:error] = paypal_prefs_form.errors.full_messages.join(", ")
    end

    @current_community.update_attributes(
      commission_from_seller: paypal_prefs_form.commission_from_seller,
      minimum_price: paypal_prefs_form.minimum_listing_price
      )

    flash[:notice] = t("admin.paypal_accounts.preferences_updated")
    redirect_to action: :index
  end

  def account_create
    PaypalAccountCommand.create_admin_account(@current_community.id)

    permissions_url = request_paypal_permissions_url

    if permissions_url.blank?
      flash[:error] = t("paypal_accounts.new.could_not_fetch_redirect_url")
      return redirect_to action: :index
    else
      return redirect_to permissions_url
    end
  end

  def permissions_verified
    unless params[:verification_code].present?
      flash[:error] = t("paypal_accounts.new.permissions_not_granted")
      return redirect_to action: :index
    end

    access_token_res = fetch_access_token(params[:request_token], params[:verification_code])
    return flash_error_and_redirect_to_settings(error_response: access_token_res) unless access_token_res[:success]

    personal_data_res = fetch_personal_data(access_token_res[:token], access_token_res[:token_secret])
    return flash_error_and_redirect_to_settings(error_response: personal_data_res) unless personal_data_res[:success]

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

    redirect_to action: :index
  end

  private

  def parse_preferences(params, currency)
    minimum_listing_price = MoneyUtil.parse_str_to_money(params[:minimum_listing_price], currency)
    {
      minimum_listing_price: minimum_listing_price,
      commission_from_seller: params[:commission_from_seller]
    }
  end

  # Before filter
  def ensure_paypal_enabled
    unless @current_community.paypal_enabled?
      flash[:error] = t("paypal_accounts.new.paypal_not_enabled")
      redirect_to edit_details_admin_community_path(@current_community)
    end
  end

  def request_paypal_permissions_url
    permission_request = PaypalService::DataTypes::Permissions
      .create_req_perm({callback: permissions_verified_admin_community_paypal_preferences_url })

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

  def flash_error_and_redirect_to_settings(error_response: nil)
    error =
      if (error_response && error_response[:error_code] == "570058")
        t("paypal_accounts.new.account_not_verified")
      else
        t("paypal_accounts.new.something_went_wrong")
      end

    flash[:error] = error
    redirect_to action: :index
  end

  def paypal_minimum_commissions_api
    PaypalService::API::Api.minimum_commissions_api
  end
end
