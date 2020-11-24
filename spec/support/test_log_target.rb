class TestLogTarget
  attr_reader(
    :debug_log,
    :info_log,
    :warn_log,
    :error_log,
    :all_log)

  def initialize
    clear!
  end

  def debug(msg)
    @debug_log.push(msg)
    @all_log.push(msg)
  end

  def info(msg)
    @info_log.push(msg)
    @all_log.push(msg)
  end

  def warn(msg)
    @warn_log.push(msg)
    @all_log.push(msg)
  end

  def error(msg)
    @error_log.push(msg)
    @all_log.push(msg)
  end

  def clear!
    @debug_log, @info_log, @warn_log, @error_log, @all_log = [], [], [], [], []
  end

  # Returns partially parsed log entries
  #
  # Usage:
  #
  # log_target = TestLogTarget
  # log_target.parsed_log(:info)
  #
  def parse_log(log_level)
    send("#{log_level}_log".to_sym).map { |log_entry| HashUtils.symbolize_keys(JSON.parse(log_entry)) }
  end
end
