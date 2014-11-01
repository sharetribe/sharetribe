# This class is for tests but I can't figure out where to put it to have
# it loaded in rspec except here. It's enabled only for test environment.
class SyncDelayedJobObserver < ActiveRecord::Observer
  observe Delayed::Job

  class << self
    attr_accessor :total_processed

    def enabled?
      @enabled
    end

    def enable!
      @enabled = true
    end

    def disable!
      @enabled = false
    end

    def reset!
      @total_processed = 0
      @enabled = false
    end
  end

  def after_create(delayed_job)
    if SyncDelayedJobObserver.enabled?
      delayed_job.invoke_job
      SyncDelayedJobObserver.total_processed += 1
    end
  end

end

SyncDelayedJobObserver.reset!
