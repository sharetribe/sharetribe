class Maintenance

  def initialize(env_value)
    @next_maintenance_at = Maintenance.parse_time_from_env(env_value)
  end

  # Returns true if warning should be shown
  #
  # Usage:
  # show_warning?(15.minutes, Time.now)
  #
  # Returns true if Time is within the "show before" timeframe or if the
  # time is in the past
  def show_warning?(show_before, now)
    if @next_maintenance_at.nil?
      false
    else
      now > (@next_maintenance_at - show_before)
    end
  end

  # Returns time (in minutes) to the next maintenance
  # Return 0 if the next maintenance is in the past or not scheduled
  def minutes_to(now)
    (time_to(now) / 60).floor
  end

  # Returns time (in seconds) to the next maintenance
  # Return 0 if the next maintenance is in the past or not scheduled
  def time_to(now)
    if @next_maintenance_at.nil?
      0
    else
      [@next_maintenance_at - now, 0].max
    end
  end

  def self.parse_time_from_env(env_value)
    if env_value.blank?
      nil
    elsif env_value.is_a?(Time)
      env_value
    elsif env_value.is_a?(String)
      Time.parse(env_value)
    else
      SharetribeLogger.warn(
        "Unknown environment variable value for next maintenance mode",
        :maintenance,
        value: env_value, class: env_value.class.name
      )
      nil
    end
  end
end
