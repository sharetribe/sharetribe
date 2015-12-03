module MonitoringService::Monitoring

  SAMPLING_PERIOD_IN_SECONDS = ENV['MONITORING_SAMPLING_PERIOD'] || 15
  @delayed_job_last_reported = 0

  module_function

  def report_queue_size
    if Librato.tracker.should_start? && should_report?
      # Priorities are from 0..10, where 0..5 are high priority and 6..10 low
      priority_counts = Delayed::Job.where('attempts < ? AND run_at < ?', 3, Time.now).group(:priority).count

      Librato.group 'delayed_job_queue' do |g|
        # We are measuring an average in the sampling period, by default 60 seconds
        g.measure 'high', priority_counts.select { |p, _| p < 6 }.values.sum
        g.measure 'low', priority_counts.select { |p, _| p >= 6 }.values.sum
      end
      @delayed_job_last_reported = Time.now
    end
  end

  def should_report?
    (Time.now - @delayed_job_last_reported).to_i > SAMPLING_PERIOD_IN_SECONDS
  end
  private_class_method :should_report?
end
