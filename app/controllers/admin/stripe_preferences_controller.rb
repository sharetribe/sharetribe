class Admin::StripePreferencesController < Admin::AdminBaseController

  MIN_COMMISSION_PERCENTAGE = 0
  MAX_COMMISSION_PERCENTAGE = 100

  StripePreferencesForm = FormUtils.define_form("StripePreferencesForm",
    :commission_from_seller,
    :minimum_listing_price,
    :minimum_commission,
    :minimum_transaction_fee,
    :marketplace_currency,
    :api_client_id,
    :api_private_key,
    :api_publishable_key
    ).with_validations do
      validates_numericality_of(
        :commission_from_seller,
        only_integer: true,
        allow_nil: false,
        greater_than_or_equal_to: MIN_COMMISSION_PERCENTAGE,
        less_than_or_equal_to: MAX_COMMISSION_PERCENTAGE)

      available_currencies = MarketplaceService::AvailableCurrencies::CURRENCIES
      validates_inclusion_of(:marketplace_currency, in: available_currencies)
      validates_format_of :api_private_key, with: Regexp.new(APP_CONFIG.stripe_private_key_pattern), allow_nil: true

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

  before_action :ensure_stripe_provisioned

  def index
    tx_settings =
      Maybe(tx_settings_api.get(community_id: @current_community.id, payment_gateway: :stripe, payment_process: :preauthorize))
      .select { |result| result[:success] }
      .map { |result| result[:data] }
      .or_else({})

    return redirect_to admin_payment_preferences_path unless tx_settings

    @payment_settings = tx_settings

    currency = @current_community.currency
    minimum_commission = Money.new(0, currency)

    stripe_prefs_form = StripePreferencesForm.new(
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
      stripe_prefs_form: stripe_prefs_form,
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

  def update
    currency = params[:stripe_preferences_form]["marketplace_currency"]
    minimum_commission = Money.new(0, currency)

    stripe_prefs_form = StripePreferencesForm.new(
      parse_preferences(params[:stripe_preferences_form], currency).merge(minimum_commission: minimum_commission))

    if stripe_prefs_form.valid?
      ActiveRecord::Base.transaction do
        @current_community.currency = currency
        @current_community.save!
        tx_settings = tx_settings_api.update({
          community_id: @current_community.id,
          payment_gateway: :stripe,
          payment_process: :preauthorize,
          commission_from_seller: stripe_prefs_form.commission_from_seller.to_i,
          minimum_price_cents: stripe_prefs_form.minimum_listing_price.cents,
          minimum_price_currency: currency,
          minimum_transaction_fee_cents: stripe_prefs_form.minimum_transaction_fee.cents,
          minimum_transaction_fee_currency: currency,
          api_client_id: stripe_prefs_form.api_client_id,
          api_private_key: stripe_prefs_form.api_private_key,
          api_publishable_key: stripe_prefs_form.api_publishable_key,
        })
      end

      state_changed = Admin::OnboardingWizard.new(@current_community.id)
        .update_from_event(:stripe_preferences_updated, @current_community)
      if state_changed
        report_to_gtm([{event: "km_record", km_event: "Onboarding payments setup"},
                       {event: "km_record", km_event: "Onboarding stripe connected"}])

        flash[:show_onboarding_popup] = true
      end
      if stripe_prefs_form.api_private_key.present? && stripe_api.check_balance(@current_community.id)
        tx_settings_api.api_verified(community_id: @current_community.id, payment_gateway: :stripe, payment_process: :preauthorize)
      end

      flash[:notice] = t("admin.stripe_preferences.update.updated")
    else
      flash[:error] = stripe_prefs_form.errors.full_messages.join(", ")
    end

    redirect_to action: :index
  end

  private

  def parse_preferences(params, currency)
    {
      minimum_listing_price: MoneyUtil.parse_str_to_money(params[:minimum_listing_price], currency),
      minimum_transaction_fee: MoneyUtil.parse_str_to_money(params[:minimum_transaction_fee], currency),
      commission_from_seller: params[:commission_from_seller],
      marketplace_currency: currency,
      api_client_id: params[:api_client_id],
      api_private_key: params[:api_private_key],
      api_publishable_key: params[:api_publishable_key],
    }
  end

  def tx_settings_api
    TransactionService::API::Api.settings
  end

  def stripe_api
    StripeService::API::Api.wrapper
  end

  # Before filter
  def ensure_stripe_provisioned
    unless StripeHelper.stripe_provisioned?(@current_community.id)
      flash[:error] = t("stripe_accounts.new.stripe_not_enabled")
      redirect_to admin_details_edit_path
    end
  end

end
