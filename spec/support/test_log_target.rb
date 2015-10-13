class TestLogTarget
  attr_reader(
    :debug_log,
    :info_log,
    :warn_log,
    :error_log,
    :all_log)

  def initialize
    @debug_log, @info_log, @warn_log, @error_log, @all_log = [], [], [], [], []
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
end
