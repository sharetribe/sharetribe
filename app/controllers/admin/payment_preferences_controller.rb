class Admin::PaymentPreferencesController < Admin::AdminBaseController

  def index
    @payment_settings = TransactionService::Store::PaymentSettings.get_all_active(community_id: @current_community.id)
    if @payment_settings.size == 1
      if @payment_settings.first[:payment_gateway] == :paypal
        redirect_to admin_paypal_preferences_path
      end
      if @payment_settings.first[:payment_gateway] == :stripe
        redirect_to admin_stripe_preferences_path
      end
    end
  end
end
