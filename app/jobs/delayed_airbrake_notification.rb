module DelayedAirbrakeNotification

  # Notify Airbrake in case of errors
  def error(job, exception)
    Airbrake.notify(exception) if APP_CONFIG.use_airbrake
  end

end
