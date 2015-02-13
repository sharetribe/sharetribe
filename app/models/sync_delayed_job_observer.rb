# This class is for tests but I can't figure out where to put it to have
# it loaded in rspec except here. It's enabled only for test environment.
class SyncDelayedJobObserver < ActiveRecord::Observer
  observe Delayed::Job

  class << self
    attr_accessor :total_processed

    def enabled?
      @enabled
    end

    def queueing?
      @collect
    end

    def collect!
      @collect = true
    end

    def enable!
      @enabled = true
    end

    def disable!
      @enabled = false
    end

    def reset!
      @job_queue = []
      @collect = false
      @total_processed = 0
      @enabled = false
    end

    def process_queue!
      jobs = @job_queue.dup
      @job_queue = []

      jobs.each { |delayed_job| process_job(delayed_job) }
    end

    def process_job(delayed_job)
      delayed_job.invoke_job
      SyncDelayedJobObserver.total_processed += 1
    end

    def enqueue(delayed_job)
      @job_queue.push(delayed_job)
    end

  end

  def after_create(delayed_job)
    if SyncDelayedJobObserver.enabled?
      SyncDelayedJobObserver.process_job(delayed_job)
    elsif SyncDelayedJobObserver.queueing?
      SyncDelayedJobObserver.enqueue(delayed_job)
    end
  end

end
