class ErrorsController < ApplicationController
  skip_filter :dashboard_only

  def server_error
    exception = env["action_dispatch.exception"]
    env["airbrake.error_id"] = Airbrake.notify(exception) if APP_CONFIG.use_airbrake

    @airbrake_url = "https://airbrake.io/locate/#{env["airbrake.error_id"]}" if env["airbrake.error_id"]
    render "500", layout: false, status: 500, :formats => [:html]
  end
end