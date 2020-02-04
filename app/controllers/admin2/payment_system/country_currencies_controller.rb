module Admin2::PaymentSystem
  class CountryCurrenciesController < Admin2::AdminBaseController
    before_action :ensure_payments_enabled

    def index
      payment_locals = { stripe_allowed: stripe_allowed,
                         paypal_allowed: paypal_allowed,
                         payments_connected: payments_connected? }
      render :index, locals: view_locals.merge(payment_locals)
    end

    def update_country_currencies
      raise t("admin2.notifications.payments_connected") if payments_connected?

      ActiveRecord::Base.transaction do
        @current_community.update!(currency: base_params[:minimum_price_currency])
        TransactionService::API::Api.settings.update(base_params)
      end
      flash[:notice] = t('admin2.notifications.country_currency_updated')
    rescue StandardError => e
      flash[:error] = e.message
    ensure
      redirect_to admin2_payment_system_country_currencies_path
    end

    def verify_currency
      @stripe_allowed = stripe_allowed(params[:currency])
      @paypal_allowed = paypal_allowed(params[:currency])
      @country_name = CountryI18nHelper.translate_country(@current_community.country)
      @currency = params[:currency]
      render layout: false
    end

    private

    def base_params
      currency = params[:community][:currency]
      { minimum_price_currency: currency,
        payment_gateway: :stripe,
        community_id: @current_community.id,
        payment_process: :preauthorize }
    end

    def view_locals
      @view_locals ||= begin
        more_locals = {}
        more_locals.merge!(paypal_index) if @paypal_enabled
        more_locals.merge!(stripe_index) if @stripe_enabled
        build_view_locals.merge(more_locals)
      end
    end

    def paypal_allowed(currency = @current_community.currency)
      TransactionService::AvailableCurrencies.paypal_allows_country_and_currency?(@current_community.country,
                                                                                  currency)
    end

    def stripe_allowed(currency = @current_community.currency)
      TransactionService::AvailableCurrencies.stripe_allows_country_and_currency?(@current_community.country,
                                                                                  currency,
                                                                                  stripe_mode)
    end

    def payments_connected?
      stripe_connected || paypal_connected
    end

    def stripe_connected
      view_locals[:stripe_enabled] && view_locals[:stripe_account] && view_locals[:stripe_account][:api_verified]
    end

    def stripe_mode
      StripeService::API::Api.wrapper.charges_mode(@current_community.id)
    end

    def paypal_connected
      view_locals[:paypal_enabled] && view_locals[:paypal_account].present?
    end

    def build_view_locals
      { available_currencies: TransactionService::AvailableCurrencies::CURRENCIES,
        currency: @current_community.currency,
        stripe_enabled: @stripe_enabled,
        paypal_enabled: @paypal_enabled,
        country_name: CountryI18nHelper.translate_country(@current_community.country) }
    end

    def ensure_payments_enabled
      @paypal_enabled = PaypalHelper.paypal_provisioned?(@current_community.id)
      @stripe_enabled = StripeHelper.stripe_provisioned?(@current_community.id)
      unless @paypal_enabled || @stripe_enabled
        flash[:error] = t("admin2.country_currency.payments_not_enabled")
        redirect_to admin2_dashboard_index_path
      end
    end

    def paypal_index
      paypal_account = PaypalService::API::Api.accounts
                                              .get(community_id: @current_community.id)
                                              .data
      { paypal_account: paypal_account }
    end

    def stripe_index
      stripe_account = stripe_tx_settings
      { stripe_account: stripe_account }
    end

    def stripe_tx_settings
      Maybe(tx_settings_by_gateway(:stripe))
        .select { |result| result[:success] }
        .map { |result| result[:data] }
        .or_else({})
    end

    def tx_settings_by_gateway(gateway)
      TransactionService::API::Api.settings.get(community_id: @current_community.id,
                                                payment_gateway: gateway,
                                                payment_process: :preauthorize)
    end
  end
end
