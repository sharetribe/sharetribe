module Admin2::PaymentSystem
  class StripeController < Admin2::AdminBaseController

    include Payments

    before_action :ensure_payments_enabled
    before_action :ensure_params_payment_gateway, only: [:enable, :disable]

    def index
      payment_index
    end

    def update_stripe_keys
      process_update_stripe_keys

      redirect_to action: :index
    end

    def common_update
      update_payment_preferences

      redirect_to action: :index
    end

    def enable
      if can_enable_gateway?
        result = tx_settings_api.activate(community_id: @current_community.id, payment_gateway: params[:payment_gateway], payment_process: :preauthorize)
        raise t('admin2.stripe.cannot_enable_gateway', gateway: params[:payment_gateway]) unless result[:success]
      else
        raise t('admin2.stripe.cannot_enable_gateway_because_of_buyer_commission', gateway: params[:payment_gateway])
      end
    rescue StandardError => e
      flash[:error] = e.message
    ensure
      redirect_to action: :index
    end

    def disable
      result = tx_settings_api.disable(community_id: @current_community.id, payment_gateway: params[:payment_gateway], payment_process: :preauthorize)
      raise t('admin2.stripe.cannot_disable_gateway', gateway: params[:payment_gateway]) unless result[:success]
    rescue StandardError => e
      flash[:error] = e.message
    ensure
      redirect_to action: :index
    end
  end
end
