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
end
