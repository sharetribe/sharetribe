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
      @locals = form_locals
      render layout: false
    rescue StandardError => e
      @error = e.message
      render layout: false, status: :unprocessable_entity
    end

    def onboarding_enable
      unless FeatureFlagHelper.feature_enabled?(:stripe_connect_onboarding)
        FeatureFlagService::API::API.features.enable(community_id: @current_community.id, features: [:stripe_connect_onboarding])
      end
      flash[:notice] = t('admin2.notifications.onboarding_enabled')
    rescue StandardError => e
      flash[:error] = e.message
    ensure
      redirect_to admin2_payment_system_stripe_index_path
    end

    def common_update
      message = update_payment_preferences

      render json: { message: message }
    rescue StandardError => e
      render json: { message: e.message }, status: :unprocessable_entity
    end
  end
end
