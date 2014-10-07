class ErrorsController < ActionController::Base

  def server_error
    @airbrake_url = nofity_airbrake
    render "500", layout: false, status: 500, :formats => [:html]
  end

  def not_found
    render "404", layouts: false, status: 404, :formats => [:html]
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
end
