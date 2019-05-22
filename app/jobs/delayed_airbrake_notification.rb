module DelayedAirbrakeNotification
  # Notify Airbrake in case of errors
  def error(job, exception, params_to_airbrake = {})
    exception.extend ParamsToAirbrake
    exception.params_to_airbrake = params_to_airbrake
    Airbrake.notify(exception) if APP_CONFIG.use_airbrake
  end

end
