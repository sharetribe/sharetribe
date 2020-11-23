class Admin::PaymentPreferencesController < Admin::AdminBaseController

  include Payments

  before_action :ensure_payments_enabled
  before_action :ensure_params_payment_gateway, only: [:enable, :disable]

  def index
    payment_index
  end

  def common_update
    message = update_payment_preferences
    flash[:notice] = message
  rescue StandardError => e
    flash[:error] = e.message
  ensure
    redirect_to action: :index
  end

  def update_stripe_keys
    process_update_stripe_keys
    flash[:notice] = t("admin.payment_preferences.stripe_verified")
  rescue StandardError => e
    flash[:error] = e.message
  ensure
    redirect_to action: :index
  end

  def enable
    if can_enable_gateway?
      result = tx_settings_api.activate(community_id: @current_community.id, payment_gateway: params[:payment_gateway], payment_process: :preauthorize)
      error_message = result[:success] ? nil : t("admin.payment_preferences.cannot_enable_gateway", gateway: params[:payment_gateway])
    else
      error_message = t("admin.payment_preferences.cannot_enable_gateway_because_of_buyer_commission", gateway: params[:payment_gateway])
    end
    redirect_to admin_payment_preferences_path, flash: {error: error_message}
  end

  def disable
    result = tx_settings_api.disable(community_id: @current_community.id, payment_gateway: params[:payment_gateway], payment_process: :preauthorize)
    error_message = result[:success] ? nil : t("admin.payment_preferences.cannot_disable_gateway", gateway: params[:payment_gateway])
    redirect_to admin_payment_preferences_path, flash: {error: error_message}
  end
end
