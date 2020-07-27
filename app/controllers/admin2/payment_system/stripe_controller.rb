module Admin2::PaymentSystem
  class StripeController < Admin2::AdminBaseController
    MIN_COMMISSION_PERCENTAGE = 0
    MAX_COMMISSION_PERCENTAGE = 100

    PaymentPreferencesForm = FormUtils.define_form("PaymentPreferencesForm",
                                                   :commission_from_seller,
                                                   :minimum_listing_price,
                                                   :minimum_commission,
                                                   :minimum_transaction_fee,
                                                   :marketplace_currency,
                                                   :mode,
                                                   :commission_from_buyer,
                                                   :minimum_buyer_transaction_fee
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
    end

    StripeApiKeysForm = FormUtils.define_form("StripeApiKeysForm",
                                              :api_private_key,
                                              :api_publishable_key).with_validations do
      validates_format_of :api_private_key, with: Regexp.new(APP_CONFIG.stripe_private_key_pattern)
      validates_format_of :api_publishable_key, with: Regexp.new(APP_CONFIG.stripe_publishable_key_pattern)
    end

    def index
      @stripe_enabled = StripeHelper.stripe_provisioned?(@current_community.id)
      more_locals = {}
      more_locals.merge!(stripe_index) if @stripe_enabled
      more_locals.merge!(build_prefs_form)
      view_locals = build_view_locals.merge(more_locals)
      payment_locals = { stripe_connected: stripe_connected,
                         stripe_allowed: stripe_allowed,
                         stripe_ready: StripeHelper.community_ready_for_payments?(@current_community.id),
                         stripe_enabled_by_admin: !!stripe_tx_settings[:active],
                         buyer_commission: buyer_commission }
      render 'index', locals: view_locals.merge(payment_locals)
    end

    def stripe_allowed(currency = @current_community.currency)
      TransactionService::AvailableCurrencies.stripe_allows_country_and_currency?(@current_community.country,
                                                                                  currency,
                                                                                  stripe_mode)
    end

    def buyer_commission
      stripe_tx_settings[:active] &&
        (stripe_tx_settings[:commission_from_buyer].to_i.positive? || stripe_tx_settings[:minimum_buyer_transaction_fee_cents].to_i.positive?)
    end

    def stripe_connected
      view_locals[:stripe_enabled] && view_locals[:stripe_account] && view_locals[:stripe_account][:api_verified]
    end

    def stripe_enabled
      StripeHelper.community_ready_for_payments?(@current_community.id)
    end

    def stripe_mode
      @stripe_mode ||= StripeService::API::Api.wrapper.charges_mode(@current_community.id)
    end

    def view_locals
      @view_locals ||= begin
                         more_locals = {}
                         more_locals.merge!(stripe_index) if @stripe_enabled
                         build_view_locals.merge(more_locals)
                       end
    end

    def build_view_locals
      { available_currencies: TransactionService::AvailableCurrencies::CURRENCIES,
        currency: @current_community.currency,
        stripe_enabled: @stripe_enabled,
        country_name: CountryI18nHelper.translate_country(@current_community.country) }
    end

    def stripe_index
      { stripe_account: stripe_tx_settings,
        stripe_api_form: StripeApiKeysForm.new }
    end

    def stripe_tx_settings
      Maybe(tx_settings_by_gateway(:stripe))
        .select { |result| result[:success] }
        .map { |result| result[:data] }
        .or_else({})
    end

    def build_prefs_form(params = nil)
      currency = @current_community.currency
      data = { stripe_prefs_form: nil }

      if @stripe_enabled
        data[:stripe_prefs_form] = prefs_form_from_settings(stripe_tx_settings, 0, currency)
      end

      form = data[:stripe_prefs_form]
      data[:payment_prefs_form] = form
      data[:payment_prefs_valid] = form.valid?
      data
    end

    def tx_settings_by_gateway(gateway)
      TransactionService::API::Api.settings.get(community_id: @current_community.id, payment_gateway: gateway, payment_process: :preauthorize)
    end

    def prefs_form_from_settings(tx_settings, minimum_commission, currency)
      PaymentPreferencesForm.new(
        minimum_commission: minimum_commission,
        commission_from_seller: tx_settings[:commission_from_seller],
        minimum_listing_price: Money.new(tx_settings[:minimum_price_cents], currency),
        minimum_transaction_fee: Money.new(tx_settings[:minimum_transaction_fee_cents], currency),
        marketplace_currency: currency,
        commission_from_buyer: tx_settings[:commission_from_buyer],
        minimum_buyer_transaction_fee: Money.new(tx_settings[:minimum_buyer_transaction_fee_cents], currency)
      )
    end
  end
end
