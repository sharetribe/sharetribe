class Admin::PaymentPreferencesController < Admin::AdminBaseController
  before_action :ensure_payments_enabled
  before_action :ensure_params_payment_gateway, only: [:enable, :disable]

  def index
    more_locals = {}

    if @paypal_enabled
      more_locals.merge!(paypal_index)
    end

    if @stripe_enabled
      more_locals.merge!(stripe_index)
    end

    more_locals.merge!(build_prefs_form)
    view_locals = build_view_locals.merge(more_locals)

    stripe_connected =  view_locals[:stripe_enabled] && view_locals[:stripe_account] && view_locals[:stripe_account][:api_verified]
    paypal_connected =  view_locals[:paypal_enabled] && view_locals[:paypal_account].present?

    stripe_mode = stripe_api.charges_mode(@current_community.id)
    payment_locals = {
      stripe_connected: stripe_connected,
      paypal_connected: paypal_connected,
      payments_connected: stripe_connected || paypal_connected,
      stripe_allowed:  TransactionService::AvailableCurrencies.stripe_allows_country_and_currency?(@current_community.country, @current_community.currency, stripe_mode),
      paypal_allowed:  TransactionService::AvailableCurrencies.paypal_allows_country_and_currency?(@current_community.country, @current_community.currency),
      stripe_ready: StripeHelper.community_ready_for_payments?(@current_community.id),
      paypal_ready: PaypalHelper.community_ready_for_payments?(@current_community.id),
      paypal_enabled_by_admin: !!paypal_tx_settings[:active],
      stripe_enabled_by_admin: !!stripe_tx_settings[:active],
    }

    render 'index', locals: view_locals.merge(payment_locals)
  end

  def common_update
    update_payment_preferences

    redirect_to action: :index
  end

  def update_stripe_keys
    process_update_stripe_keys

    redirect_to action: :index
  end

  def enable
    result = tx_settings_api.activate(community_id: @current_community.id, payment_gateway: params[:payment_gateway], payment_process: :preauthorize)
    error_message = result[:success] ? nil : t("admin.payment_preferences.cannot_enable_gateway", gateway: params[:payment_gateway])
    redirect_to admin_payment_preferences_path, error: error_message
  end

  def disable
    result = tx_settings_api.disable(community_id: @current_community.id, payment_gateway: params[:payment_gateway], payment_process: :preauthorize)
    error_message = result[:success] ? nil : t("admin.payment_preferences.cannot_disable_gateway", gateway: params[:payment_gateway])
    redirect_to admin_payment_preferences_path, error: error_message
  end

  private

  MIN_COMMISSION_PERCENTAGE = 0
  MAX_COMMISSION_PERCENTAGE = 100

  def ensure_payments_enabled
    @paypal_enabled = PaypalHelper.paypal_provisioned?(@current_community.id)
    @stripe_enabled = StripeHelper.stripe_provisioned?(@current_community.id)
    unless @paypal_enabled || @stripe_enabled
      flash[:error] = t("admin.communities.settings.payments_not_enabled")
      redirect_to admin_details_edit_path
    end
  end

  def paypal_index
    paypal_account = paypal_accounts_api.get(community_id: @current_community.id).data

    {
      order_permission_action: admin_paypal_preferences_account_create_path(),
      paypal_account: paypal_account
    }
  end

  def stripe_index
    stripe_account = stripe_tx_settings
    {
      stripe_account: stripe_account,
      stripe_api_form: StripeApiKeysForm.new
    }
  end

  def tx_settings_by_gateway(gateway)
    tx_settings_api.get(community_id: @current_community.id, payment_gateway: gateway, payment_process: :preauthorize)
  end

  def paypal_tx_settings
    Maybe(tx_settings_by_gateway(:paypal))
    .select { |result| result[:success] }
    .map { |result| result[:data] }
    .or_else({})
  end

  def stripe_tx_settings
    Maybe(tx_settings_by_gateway(:stripe))
    .select { |result| result[:success] }
    .map { |result| result[:data] }
    .or_else({})
  end

  def active_tx_setttings
    if @paypal_enabled
      paypal_tx_settings
    else
      stripe_tx_settings
    end
  end

  def build_prefs_form(params = nil)
    currency = @current_community.currency
    data = {paypal_prefs_form: nil, stripe_prefs_form: nil}

    if @paypal_enabled
      data[:paypal_prefs_form] = prefs_form_from_settings(paypal_tx_settings, paypal_minimum_commissions_api.get(currency), currency)
    end
    if @stripe_enabled
      data[:stripe_prefs_form] = prefs_form_from_settings(stripe_tx_settings, 0, currency)
    end

    form = data[:paypal_prefs_form] || data[:stripe_prefs_form]
    data[:payment_prefs_form] = form
    data[:payment_prefs_valid] = form.valid?
    data
  end

  def prefs_form_from_settings(tx_settings, minimum_commission, currency)
    PaymentPreferencesForm.new(
      minimum_commission: minimum_commission,
      commission_from_seller: tx_settings[:commission_from_seller],
      minimum_listing_price: Money.new(tx_settings[:minimum_price_cents], currency),
      minimum_transaction_fee: Money.new(tx_settings[:minimum_transaction_fee_cents], currency),
      marketplace_currency: currency
    )
  end

  def build_view_locals
    @selected_left_navi_link = "payment_preferences"
    make_onboarding_popup

    {
      min_commission_percentage: MIN_COMMISSION_PERCENTAGE,
      max_commission_percentage: MAX_COMMISSION_PERCENTAGE,
      available_currencies: TransactionService::AvailableCurrencies::CURRENCIES,
      currency: @current_community.currency,
      display_knowledge_base_articles: APP_CONFIG.display_knowledge_base_articles,
      knowledge_base_url: APP_CONFIG.knowledge_base_url,
      support_email: APP_CONFIG.support_email,
      stripe_enabled: @stripe_enabled,
      paypal_enabled: @paypal_enabled,
      stripe_account: nil,
      paypal_account: nil,
      country_name: CountryI18nHelper.translate_country(@current_community.country)
    }
  end

  PaymentPreferencesForm = FormUtils.define_form("PaymentPreferencesForm",
    :commission_from_seller,
    :minimum_listing_price,
    :minimum_commission,
    :minimum_transaction_fee,
    :marketplace_currency,
    :mode
    ).with_validations do
      validates_numericality_of(
        :commission_from_seller,
        only_integer: true,
        allow_nil: false,
        greater_than_or_equal_to: MIN_COMMISSION_PERCENTAGE,
        less_than_or_equal_to: MAX_COMMISSION_PERCENTAGE,
        if: proc { mode == 'transaction_fee' || mode == 'paypal' }
      )

      available_currencies = TransactionService::AvailableCurrencies::CURRENCIES
      validates_inclusion_of(:marketplace_currency, in: available_currencies)

      validate do |prefs|
        if minimum_listing_price.nil? || minimum_listing_price < (minimum_commission || 0)
          prefs.errors[:base] << I18n.t("admin.paypal_accounts.minimum_listing_price_below_min",
                                        { minimum_commission: minimum_commission })
        elsif minimum_transaction_fee && minimum_listing_price < minimum_transaction_fee
          prefs.errors[:base] << I18n.t("admin.paypal_accounts.minimum_listing_price_below_tx_fee",
                                        { minimum_transaction_fee: minimum_transaction_fee })
        end
      end
    end

  def update_payment_preferences
    currency = params[:payment_preferences_form]["marketplace_currency"] || @current_community.currency

    minimum_commission = @paypal_enabled ? (paypal_minimum_commissions_api.get(currency) || 0) : 0

    form = PaymentPreferencesForm.new(parse_preferences(params[:payment_preferences_form], currency).merge(minimum_commission: minimum_commission))
    if form.valid?
      ActiveRecord::Base.transaction do
        @current_community.currency = currency
        @current_community.save!

        base_params = if form.mode == 'transaction_fee'
          {
            community_id: @current_community.id,
            payment_process: :preauthorize,
            commission_from_seller: form.commission_from_seller,
            minimum_transaction_fee_cents: form.minimum_transaction_fee.try(:cents),
            minimum_transaction_fee_currency: currency
          }.compact
        elsif form.mode == 'paypal'
          {
            community_id: @current_community.id,
            payment_process: :preauthorize,
            commission_from_seller: form.commission_from_seller,
            minimum_transaction_fee_cents: form.minimum_transaction_fee.try(:cents),
            minimum_transaction_fee_currency: currency,
            minimum_price_cents: form.minimum_listing_price.try(:cents),
            minimum_price_currency: currency

          }.compact
        else
          {
            community_id: @current_community.id,
            payment_process: :preauthorize,
            minimum_price_cents: form.minimum_listing_price.try(:cents),
            minimum_price_currency: currency
          }.compact
        end

        if paypal_tx_settings.present? && (params[:gateway] == 'paypal' || form.mode == 'general')
          tx_settings_api.update(base_params.merge(payment_gateway: :paypal))
        end
        if stripe_tx_settings.present? && (params[:gateway] == 'stripe'|| form.mode == 'general')
          tx_settings_api.update(base_params.merge(payment_gateway: :stripe))
        end
      end

      if form.mode == 'transaction_fee' || form.mode == 'paypal'
        # Onboarding wizard step recording
        state_changed = Admin::OnboardingWizard.new(@current_community.id)
          .update_from_event(:payment_preferences_updated, @current_community)
        if state_changed
          record_event(flash, "km_record", {km_event: "Onboarding payments setup"})
          record_event(flash, "km_record", {km_event: "Onboarding paypal connected"})

          flash[:show_onboarding_popup] = true
        end
        flash[:notice] = t("admin.payment_preferences.transaction_fee_settings_updated")
      else
        flash[:notice] = t("admin.payment_preferences.general_settings_updated")
      end
    else
      flash[:error] = form.errors.full_messages.join(", ")
    end
  end

  def paypal_minimum_commissions_api
    PaypalService::API::Api.minimum_commissions
  end

  def tx_settings_api
    TransactionService::API::Api.settings
  end

  def paypal_accounts_api
    PaypalService::API::Api.accounts
  end

  def parse_money_with_default(str_value, default, currency)
    if str_value.present?
      MoneyUtil.parse_str_to_money(str_value, currency)
    elsif default.present?
      Money.new(default.to_i, currency)
    end
  end

  def parse_preferences(params, currency)
    tx_settings = active_tx_setttings
    tx_fee =  parse_money_with_default(params[:minimum_transaction_fee], tx_settings[:minimum_transaction_fee_cents], currency)
    tx_commission = params[:commission_from_seller] || tx_settings[:commission_from_seller]
    tx_commission = tx_commission.present? ? tx_commission.to_i : nil
    tx_min_price = parse_money_with_default(params[:minimum_listing_price], tx_settings[:minimum_price_cents], currency)

    {
      minimum_listing_price: tx_min_price,
      minimum_transaction_fee: tx_fee,
      commission_from_seller: tx_commission,
      marketplace_currency: currency,
      mode: params[:mode],
    }
  end

  StripeApiKeysForm = FormUtils.define_form("StripeApiKeysForm",
    :api_private_key,
    :api_publishable_key).with_validations do
    validates_format_of :api_private_key, with: Regexp.new(APP_CONFIG.stripe_private_key_pattern)
    validates_format_of :api_publishable_key, with: Regexp.new(APP_CONFIG.stripe_publishable_key_pattern)
  end

  def process_update_stripe_keys
    api_form = StripeApiKeysForm.new(params[:stripe_api_keys_form])
    if api_form.valid? && api_form.api_private_key.present?
      if !@stripe_enabled
        tx_settings_api.provision({ community_id: @current_community.id,
                                    payment_process: :preauthorize,
                                    payment_gateway: :stripe,
                                    api_private_key: api_form.api_private_key,
                                    api_publishable_key: api_form.api_publishable_key
                                   })
      else
        tx_settings_api.update({ community_id: @current_community.id,
                                 payment_process: :preauthorize,
                                 payment_gateway: :stripe,
                                 api_private_key: api_form.api_private_key,
                                 api_publishable_key: api_form.api_publishable_key
                                })
      end
      if stripe_api.check_balance(community: @current_community.id)
        tx_settings_api.api_verified(community_id: @current_community.id, payment_gateway: :stripe, payment_process: :preauthorize)
        tx_settings_api.activate(community_id: @current_community.id, payment_gateway: :stripe, payment_process: :preauthorize)
        flash[:notice] = t("admin.payment_preferences.stripe_verified")
      else
        tx_settings_api.disable(community_id: @current_community.id, payment_gateway: :stripe, payment_process: :preauthorize)
        flash[:error] = t("admin.payment_preferences.invalid_api_keys")
      end
    else
      flash[:error] = t("admin.payment_preferences.missing_api_keys")
    end
  end

  def stripe_api
    StripeService::API::Api.wrapper
  end

  def ensure_params_payment_gateway
    ['stripe', 'paypal'].include?(params[:payment_gateway])
  end
end
