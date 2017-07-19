class Admin::PaypalPreferencesController < Admin::AdminBaseController

  before_action :ensure_paypal_provisioned

  PaypalAccountForm = FormUtils.define_form("PaypalAccountForm", :paypal_email, :commission_from_seller)
    .with_validations { validates_presence_of :paypal_email }

  MIN_COMMISSION_PERCENTAGE = 0
  MAX_COMMISSION_PERCENTAGE = 100

  PaypalPreferencesForm = FormUtils.define_form("PaypalPreferencesForm",
    :commission_from_seller,
    :minimum_listing_price,
    :minimum_commission,
    :minimum_transaction_fee,
    :marketplace_currency
    ).with_validations do
      validates_numericality_of(
        :commission_from_seller,
        only_integer: true,
        allow_nil: false,
        greater_than_or_equal_to: MIN_COMMISSION_PERCENTAGE,
        less_than_or_equal_to: MAX_COMMISSION_PERCENTAGE)

      available_currencies = MarketplaceService::AvailableCurrencies::CURRENCIES
      validates_inclusion_of(:marketplace_currency, in: available_currencies)

      validate do |prefs|
        if minimum_listing_price.nil? || minimum_listing_price < minimum_commission
          prefs.errors[:base] << I18n.t("admin.paypal_accounts.minimum_listing_price_below_min",
                                        { minimum_commission: minimum_commission })
        elsif minimum_transaction_fee && minimum_listing_price < minimum_transaction_fee
          prefs.errors[:base] << I18n.t("admin.paypal_accounts.minimum_listing_price_below_tx_fee",
                                        { minimum_transaction_fee: minimum_transaction_fee })
        end
      end
    end

  def index
    @selected_left_navi_link = "paypal_account"
    paypal_account = accounts_api.get(community_id: @current_community.id).maybe
    currency = @current_community.currency
    minimum_commission = paypal_minimum_commissions_api.get(currency)

    tx_settings =
      Maybe(tx_settings_api.get(community_id: @current_community.id, payment_gateway: :paypal, payment_process: :preauthorize))
      .select { |result| result[:success] }
      .map { |result| result[:data] }
      .or_else({})

    paypal_prefs_form = PaypalPreferencesForm.new(
      minimum_commission: minimum_commission,
      commission_from_seller: tx_settings[:commission_from_seller],
      minimum_listing_price: Money.new(tx_settings[:minimum_price_cents], currency),
      minimum_transaction_fee: Money.new(tx_settings[:minimum_transaction_fee_cents], currency),
      marketplace_currency: currency
    )

    community_country_code = LocalizationUtils.valid_country_code(@current_community.country)

    onboarding_popup_locals = OnboardingViewUtils.popup_locals(
      flash[:show_onboarding_popup],
      admin_getting_started_guide_path,
      Admin::OnboardingWizard.new(@current_community.id).setup_status)

    available_currencies = MarketplaceService::AvailableCurrencies::CURRENCIES

    view_locals = {
      paypal_account_email: paypal_account[:email].or_else(nil),
      order_permission_action: admin_paypal_preferences_account_create_path(),
      paypal_account_form: PaypalAccountForm.new,
      paypal_prefs_valid: paypal_prefs_form.valid?,
      paypal_prefs_form: paypal_prefs_form,
      paypal_prefs_form_action: admin_paypal_preferences_preferences_update_path(),
      min_commission_percentage: MIN_COMMISSION_PERCENTAGE,
      max_commission_percentage: MAX_COMMISSION_PERCENTAGE,
      available_currencies: available_currencies,
      currency: currency,
      display_knowledge_base_articles: APP_CONFIG.display_knowledge_base_articles,
      knowledge_base_url: APP_CONFIG.knowledge_base_url,
      support_email: APP_CONFIG.support_email
    }

    render("index", locals: onboarding_popup_locals.merge(view_locals))
  end

  def preferences_update
    currency = params[:paypal_preferences_form]["marketplace_currency"]
    minimum_commission = paypal_minimum_commissions_api.get(currency)

    paypal_prefs_form = PaypalPreferencesForm.new(
      parse_preferences(params[:paypal_preferences_form], currency).merge(minimum_commission: minimum_commission))

    if paypal_prefs_form.valid?
      ActiveRecord::Base.transaction do
        @current_community.currency = currency
        @current_community.save!
        tx_settings_api.update({community_id: @current_community.id,
                                payment_gateway: :paypal,
                                payment_process: :preauthorize,
                                commission_from_seller: paypal_prefs_form.commission_from_seller.to_i,
                                minimum_price_cents: paypal_prefs_form.minimum_listing_price.cents,
                                minimum_price_currency: currency,
                                minimum_transaction_fee_cents: paypal_prefs_form.minimum_transaction_fee.cents,
                                minimum_transaction_fee_currency: currency})
      end

      # Onboarding wizard step recording
      state_changed = Admin::OnboardingWizard.new(@current_community.id)
        .update_from_event(:paypal_preferences_updated, @current_community)
      if state_changed
        report_to_gtm([{event: "km_record", km_event: "Onboarding payments setup"},
                       {event: "km_record", km_event: "Onboarding paypal connected"}])

        flash[:show_onboarding_popup] = true
      end

      flash[:notice] = t("admin.paypal_accounts.preferences_updated")
    else
      flash[:error] = paypal_prefs_form.errors.full_messages.join(", ")
    end

    redirect_to action: :index
  end

  def account_create
    community_country_code = LocalizationUtils.valid_country_code(@current_community.country)
    response = accounts_api.request(
      body: PaypalService::API::DataTypes.create_create_account_request(
      {
        community_id: @current_community.id,
        callback_url: admin_paypal_preferences_permissions_verified_url,
        country: community_country_code
      }))
    permissions_url = response.data[:redirect_url]

    if permissions_url.blank?
      flash[:error] = t("paypal_accounts.new.could_not_fetch_redirect_url")
      return redirect_to admin_payment_preferences_path
    else
      render json: {redirect_url: permissions_url}
    end
  end

  def permissions_verified
    unless params[:verification_code].present?
      flash[:error] = t("paypal_accounts.new.permissions_not_granted")
      return redirect_to admin_payment_preferences_path
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
    {
      minimum_listing_price: MoneyUtil.parse_str_to_money(params[:minimum_listing_price], currency),
      minimum_transaction_fee: MoneyUtil.parse_str_to_money(params[:minimum_transaction_fee], currency),
      commission_from_seller: params[:commission_from_seller],
      marketplace_currency: currency
    }
  end

  # Before filter
  def ensure_paypal_provisioned
    unless PaypalHelper.paypal_provisioned?(@current_community.id)
      flash[:error] = t("paypal_accounts.new.paypal_not_enabled")
      redirect_to admin_details_edit_path
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
    PaypalService::API::Api.minimum_commissions
  end

  def tx_settings_api
    TransactionService::API::Api.settings
  end

  def accounts_api
    PaypalService::API::Api.accounts
  end

end
