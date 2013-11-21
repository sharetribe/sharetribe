class EmailController < ApplicationController

  before_filter do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_change_profile_settings")
  end

  skip_filter :dashboard_only

  def destroy
    # TODO
  end
end
