class BraintreeAccountsController < ApplicationController
  before_filter do |controller|
    # FIXME Change copy text
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_change_profile_settings")
  end

  skip_filter :dashboard_only

  def create
    BraintreeAccount.create(params[:braintree_account])
    redirect_to payments_person_settings_path(@current_user)
  end
end
