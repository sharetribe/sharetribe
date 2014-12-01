class ErrorsController < ActionController::Base

  layout 'error_layout'
  before_filter :current_community
  before_filter :set_locale

  def server_error
    error_id = nofity_airbrake
    # error_id = 12341234153 # uncomment this to test the last text paragraph
    render "status_500", status: 500, locals: { status: 500, title: title(500), error_id: error_id }
  end

  def not_found
    render "status_404", status: 404, locals: { status: 404, title: title(404) }
  end

  private

  def current_community
    @current_community ||= Community.find_by_domain(request.host)
  end

  def title(status)
    community_name = Maybe(@current_community).name.or_else(nil)

    [community_name, t("error_pages.error_#{status}_title")].uniq.join(' - ')
  end

  def set_locale
    I18n.locale = Maybe(@current_community).default_locale.or_else("en")
  end

  def exception
    env["action_dispatch.exception"]
  end

  def nofity_airbrake
    Airbrake.notify(exception) if can_notify_airbrake && use_airbrake
  end

  def can_notify_airbrake
    Airbrake && Airbrake.respond_to?(:notify)
  end

  def use_airbrake
    APP_CONFIG && APP_CONFIG.use_airbrake
  end

end
