class EmailsController < ApplicationController

  before_filter do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_change_profile_settings")
  end

  skip_filter :dashboard_only

  def send_confirmation
    @email = Email.find(params[:id])
    Email.send_confirmation(@email, request.host_with_port, @current_community)
    flash[:notice] = t("sessions.confirmation_pending.check_your_email")
    redirect_to account_person_settings_path(@current_user)
  end

  def destroy
    # TODO
  end
end
