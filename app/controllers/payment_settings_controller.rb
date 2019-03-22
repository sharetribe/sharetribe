class PaymentSettingsController < ApplicationController
  before_action do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_view_your_settings")
  end

  before_action :set_service
  before_action :ensure_payments_enabled
  skip_before_action :warn_about_missing_payment_info, only: [:update]

  def index; end

  def create
    unless @presenter.stripe_enabled
      redirect_to action: :index
    end

    @service.create
    flash.now[:error] = @service.stripe_error_message

    warn_about_missing_payment_info
    render 'index'
  end

  def update
    unless (@presenter.stripe_enabled && @presenter.stripe_account_ready)
      redirect_to action: :index
    end

    @service.update
    flash.now[:error] = @service.stripe_error_message

    warn_about_missing_payment_info
    render 'index'
  end

  private

  def set_service
    @selected_left_navi_link = "payments"
    @service = Person::PaymentSettingsService.new(community: @current_community,
                                                  params: params,
                                                  person: @current_user)
    @presenter = Person::PaymentSettingsPresenter.new(service: @service,
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
