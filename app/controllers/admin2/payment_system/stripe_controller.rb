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
  end
end
