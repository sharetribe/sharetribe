class PaymentSettingsController < ApplicationController
  before_action do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_view_your_settings")
  end

  before_action :set_service
  before_action :ensure_payments_enabled
  skip_before_action :warn_about_missing_payment_info, only: %i[update stripe_callback]

  def index; end

  def create
    unless @presenter.stripe_enabled
      redirect_to action: :index
    end

    if params[:stripe_account_form_onboarding].present?
      @service.create_onboarding(client_ip_address: request.remote_ip)
    else
      @service.create
    end

    flash.now[:error] = @service.stripe_error_message

    warn_about_missing_payment_info
    render 'index'
  end

  def stripe_callback
    save_stripe_bank_id
    redirect_to person_payment_settings_path(@current_user.username)
  end

  def redirect_to_stripe
    stripe_seller_id = StripeAccount.find_by(person_id: @current_user, community_id: @current_community.id)&.stripe_seller_id
    raise t('stripe_accounts.seller_account_not_connected') if stripe_seller_id.blank?

    link = @presenter.account_link(stripe_seller_id: stripe_seller_id, return_url: person_payment_settings_stripe_callback_url)

    redirect_to link
  rescue StandardError => e
    flash[:error] = e.message
    redirect_to person_payment_settings_path(@current_user.username)
  end

  def update
    unless @presenter.stripe_enabled && @presenter.stripe_account_ready
      redirect_to action: :index
    end

    @service.update
    flash.now[:error] = @service.stripe_error_message

    warn_about_missing_payment_info
    render 'index'
  end

  private

  def save_stripe_bank_id
    stripe_account = StripeAccount.find_by(person_id: @current_user, community_id: @current_community.id)
    if stripe_account.blank?
      flash[:error] = t('stripe_accounts.seller_account_not_connected')
      return
    end

    stripe_bank_id = @presenter.stripe_bank_id
    if stripe_bank_id.blank?
      flash[:error] = t('stripe_accounts.bank_account_not_connected')
    else
      stripe_account.update_column(:stripe_bank_id, stripe_bank_id)
    end
  end

  def set_service
    @selected_left_navi_link = "payments"
    @service = Person::PaymentSettingsService.new(community: @current_community,
                                                  params: params,
                                                  person: @current_user,
                                                  person_url: person_url(@current_user.username))
    @presenter = Person::PaymentSettingsPresenter.new(service: @service,
                                                      person_id: @current_user.id,
                                                      person_url: person_url(@current_user.username))
  end

  def ensure_payments_enabled
    unless @presenter.payments_enabled?
      flash[:warning] = t("stripe_accounts.admin_account_not_connected",
                            contact_admin_link: view_context.link_to(
                              t("stripe_accounts.contact_admin_link_text"),
                                new_user_feedback_path)).html_safe # rubocop:disable Rails/OutputSafety
      redirect_to person_settings_path
    end
  end
end
