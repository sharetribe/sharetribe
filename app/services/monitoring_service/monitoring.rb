module MonitoringService::Monitoring
  module LibratoReporter
    module_function

    def report(group, measurements)
      Librato.group group do |g|
        measurements.each { |key, value|
          g.measure key.to_s, value
        }
      end
    end
  end

  module NoOpReporter
    module_function

    def report(*)
      # No op
    end
  end

  SAMPLING_PERIOD_IN_SECONDS = ENV['MONITORING_SAMPLING_PERIOD'].to_i || 15
  @delayed_job_last_reported = 0

  module_function

  def report_queue_size

    if should_report?
      @delayed_job_last_reported = Time.now

      # Priorities are from 0..10, where 0..5 are high priority and 6..10 low
      priority_counts = Delayed::Job.where('attempts < ? AND run_at < ?', 3, Time.now).group(:priority).count

      # We are measuring an average in the sampling period, by default 60 seconds
      measurements = {
        high: priority_counts.select { |p, _| p < 6 }.values.sum,
        low: priority_counts.select { |p, _| p >= 6 }.values.sum
      }

      begin
        enabled = Librato.tracker.should_start?
        reporter(enabled).report("delayed_job_queue", measurements)
      rescue StandardError => e
        SharetribeLogger.new(:monitoring).error(e.message, :librato)
      end
    end
  end

  ## Private

  def should_report?
    (Time.now - @delayed_job_last_reported).to_i > SAMPLING_PERIOD_IN_SECONDS
  end
  private_class_method :should_report?

  def reporter(enabled)
    if enabled
      LibratoReporter
    else
      NoOpReporter
    end
  end
end
