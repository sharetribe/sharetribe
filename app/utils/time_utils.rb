module TimeUtils
  module_function

  # Parse string which is in UTC and doesn't include timezone information
  # to Time.
  #
  # This is especially useful for parsing date information from MySQL
  #
  # utc_str_to_time("2004-12-12 13:00:05") => Sun, 12 Dec 2004 13:00:05 UTC +00:00
  #
  def utc_str_to_time(str)
    ActiveSupport::TimeZone["UTC"].parse(str)
  end

  # Example:
  #
  # time_to(<15 seconds>)  => {unit: :seconds, count: 15}
  # time_to(<59 seconds>)  => {unit: :seconds, count: 59}
  # time_to(<60 seconds>)  => {unit: :minutes, count: 1}
  # time_to(<61 seconds>)  => {unit: :minutes, count: 1}
  # time_to(<119 seconds>) => {unit: :minutes, count: 1}
  # time_to(<120 seconds>) => {unit: :minutes, count: 2}
  # time_to(<59 minutes>)  => {unit: :minutes, count: 59}
  # time_to(<60 minutes>)  => {unit: :hours, count: 1}
  # time_to(<61 minutes>)  => {unit: :hours, count: 1}
  # time_to(<119 minutes>) => {unit: :hours, count: 1}
  # time_to(<120 minutes>) => {unit: :hours, count: 2}
  # time_to(<23 hours>)    => {unit: :hours, count: 23}
  # time_to(<24 hours>)    => {unit: :days, count: 1}
  # time_to(<25 hours>)    => {unit: :days, count: 1}
  # time_to(<47 hours>)    => {unit: :days, count: 1}
  # time_to(<48 hours>)    => {unit: :days, count: 2}
  # time_to(<30 days>)     => {unit: :days, count: 30}
  #
  # This is a bit similar than application_helper.rb time_ago method
  #
  def time_to(to_time, from_time = Time.now)
    multiplies = [
      [:seconds, 1],
      [:minutes, 60],
      [:hours, 60*60],
      [:days, 60*60*24]
      # add more if needed
    ]

    diff = (to_time - from_time).to_i

    raise ArgumentError.new("to_time cannot be less than from_time") if diff < 0

    multiplies.inject([:seconds, diff]) { |result, (unit, multiplier)|
      if diff >= multiplier
        {unit: unit, count: (diff / multiplier)}
      else
        result
      end
    }
  end
end
