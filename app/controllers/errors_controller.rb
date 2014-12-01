class ErrorsController < ActionController::Base

  layout 'error_layout'

  def server_error
    @favicon = favicon # Rails makes it very hard to pass locals to layout...
    @airbrake_url = nofity_airbrake
    render "status_500", status: 500, locals: { status: 500 }
  end

  def not_found
    @favicon = favicon # Rails makes it very hard to pass locals to layout...
    render "status_404", status: 404, locals: { status: 404 }
  end

  def exception
    env["action_dispatch.exception"]
  end

  def nofity_airbrake
    env["airbrake.error_id"] = Airbrake.notify(exception) if can_notify_airbrake && use_airbrake
    "https://airbrake.io/locate/#{env["airbrake.error_id"]}" if env["airbrake.error_id"]
  end

  def can_notify_airbrake
    Airbrake && Airbrake.respond_to?(:notify)
  end

  def use_airbrake
    APP_CONFIG && APP_CONFIG.use_airbrake
  end

  private

  def favicon
    Maybe(Community.find_by_domain(request.host)).favicon.or_else(nil)
  end
end
