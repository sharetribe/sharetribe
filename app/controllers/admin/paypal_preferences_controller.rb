class Admin::PaypalPreferencesController < ApplicationController
  before_filter :ensure_is_admin
  before_filter :ensure_paypal_provisioned

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
    paypal_account = accounts_api.get(community_id: @current_community.id).maybe
    currency = @current_community.default_currency
    minimum_commission = paypal_minimum_commissions_api.get(currency)

    tx_settings =
      Maybe(tx_settings_api.get(community_id: @current_community.id, payment_gateway: :paypal, payment_process: :preauthorize))
      .select { |result| result[:success] }
      .map { |result| result[:data] }
      .or_else({})

    paypal_prefs_form = PaypalPreferencesForm.new(
      minimum_commission: minimum_commission,
      commission_from_seller: tx_settings[:commission_from_seller],
      minimum_listing_price: Money.new(tx_settings[:minimum_price_cents], @current_community.default_currency))

    community_country_code = LocalizationUtils.valid_country_code(@current_community.country)

    render("index", locals: {
        paypal_account_email: paypal_account[:email].or_else(nil),
        order_permission_action: account_create_admin_community_paypal_preferences_path(@current_community.id),
        paypal_account_form: PaypalAccountForm.new,
        paypal_prefs_valid: paypal_prefs_form.valid?,
        paypal_prefs_form: paypal_prefs_form,
        paypal_prefs_form_action: preferences_update_admin_community_paypal_preferences_path(@current_community.id),
        min_commission: minimum_commission,
        min_commission_percentage: 5,
        max_commission_percentage: 100,
        currency: currency,
        create_url: "https://www.paypal.com/#{community_country_code}/signup",
        upgrade_url: "https://www.paypal.com/#{community_country_code}/upgrade",
        display_knowledge_base_articles: APP_CONFIG.display_knowledge_base_articles,
        knowledge_base_url: APP_CONFIG.knowledge_base_url
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

    tx_settings_api.update({community_id: @current_community.id,
                            payment_gateway: :paypal,
                            payment_process: :preauthorize,
                            commission_from_seller: paypal_prefs_form.commission_from_seller.to_i,
                            minimum_price_cents: paypal_prefs_form.minimum_listing_price.cents})

    flash[:notice] = t("admin.paypal_accounts.preferences_updated")
    redirect_to action: :index
  end

  def account_create
    community_country_code = LocalizationUtils.valid_country_code(@current_community.country)
    response = accounts_api.request(
      body: PaypalService::API::DataTypes.create_create_account_request(
      {
        community_id: @current_community.id,
        callback_url: permissions_verified_admin_community_paypal_preferences_url,
        country: community_country_code
      }))
    permissions_url = response.data[:redirect_url]

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

    response = accounts_api.create(
      community_id: @current_community.id,
      order_permission_request_token: params[:request_token],
      body: PaypalService::API::DataTypes
        .create_account_permission_verification_request(
          {
            order_permission_verification_code: params[:verification_code]
          }))

    if response[:success]
      redirect_to action: :index
    else
      flash_error_and_redirect_to_settings(error_response: response)
    end
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
  def ensure_paypal_provisioned
    unless PaypalHelper.paypal_provisioned?(@current_community.id)
      flash[:error] = t("paypal_accounts.new.paypal_not_enabled")
      redirect_to edit_details_admin_community_path(@current_community)
    end
  end

  def flash_error_and_redirect_to_settings(error_response: nil)
    error =
      if (error_response && error_response[:error_code] == "570058")
        t("paypal_accounts.new.account_not_verified")
      elsif (error_response && error_response[:error_code] == "520009")
        t("paypal_accounts.new.account_restricted")
      else
        t("paypal_accounts.new.something_went_wrong")
      end

    flash[:error] = error
    redirect_to action: :index
  end

  def paypal_minimum_commissions_api
    PaypalService::API::Api.minimum_commissions_api
  end

  def tx_settings_api
    TransactionService::API::Api.settings
  end

  def accounts_api
    PaypalService::API::Api.accounts_api
  end

end
