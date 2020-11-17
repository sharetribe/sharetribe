module Admin2::PaymentSystem
  class TransactionSizeController < Admin2::AdminBaseController
    before_action :ensure_payments_enabled

    def index
      @current_min_price = Money.new(active_tx_settings[:minimum_price_cents], currency)
      fee = [stripe_tx_settings[:minimum_transaction_fee_cents].to_i,
             stripe_tx_settings[:minimum_buyer_transaction_fee_cents].to_i,
             paypal_tx_settings[:minimum_transaction_fee_cents].to_i].max
      @current_fee = Money.new(fee, currency)
    end

    def save
      minimum_listing_price = params[:minimum_listing_price].presence
      tx_min_price = parse_money_with_default(minimum_listing_price, active_tx_settings[:minimum_price_cents], currency)
      verify_price(tx_min_price)

      base_params = { community_id: @current_community.id,
                      payment_process: :preauthorize,
                      minimum_price_cents: tx_min_price.try(:cents) }.compact

      tx_settings_api.update(base_params.merge(payment_gateway: :paypal)) if paypal_tx_settings.present?
      tx_settings_api.update(base_params.merge(payment_gateway: :stripe)) if stripe_tx_settings.present?
      render json: { message: t('admin2.notifications.transaction_size_updated') }
    rescue StandardError => e
      render json: { message: e.message }, status: :unprocessable_entity
    end

    def minimum_commission
      @minimum_commission ||= if @paypal_enabled
                                PaypalService::API::Api.minimum_commissions.get(currency) || 0
                              else
                                0
                              end
    end

    def verify_price(tx_min_price)
      if tx_min_price.nil? || tx_min_price <= (minimum_commission || 0)
        raise I18n.t('admin2.transaction_size.errors.minimum_listing_price_below_min', minimum_commission: minimum_commission)
      elsif minimum_transaction_fee && tx_min_price <= minimum_transaction_fee
        raise I18n.t('admin2.transaction_size.errors.minimum_listing_price_below_tx_fee', minimum_transaction_fee: minimum_transaction_fee)
      end
    end

    def minimum_transaction_fee
      minimum_transaction_fee_cents = PaymentSettings.max_minimum_transaction_fee(@current_community)
      parse_money_with_default(nil, minimum_transaction_fee_cents, currency)
    end

    def tx_settings_api
      TransactionService::API::Api.settings
    end

    def parse_money_with_default(str_value, default, currency)
      if str_value.present?
        MoneyUtil.parse_str_to_money(str_value, currency)
      elsif default.present?
        Money.new(default.to_i, currency)
      end
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

    def tx_settings_by_gateway(gateway)
      tx_settings_api.get(community_id: @current_community.id,
                          payment_gateway: gateway,
                          payment_process: :preauthorize)
    end

    def active_tx_settings
      @active_tx_settings ||= if @paypal_enabled
                                paypal_tx_settings
                              else
                                stripe_tx_settings
                              end
    end

    def ensure_payments_enabled
      @paypal_enabled = PaypalHelper.paypal_provisioned?(@current_community.id)
      @stripe_enabled = StripeHelper.stripe_provisioned?(@current_community.id)
      unless @paypal_enabled || @stripe_enabled
        flash[:error] = t('admin2.transaction_size.errors.payments_not_enabled')
        redirect_to admin2_path
      end
    end

    def currency
      @current_community.currency
    end
  end
end
