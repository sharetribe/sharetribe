require 'delayed_job'

class SyncDelayedJobObserver

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
      @enabled = false
      Delayed::Worker.delay_jobs = true
    end

    def enable!
      @collect = false
      @enabled = true
      Delayed::Worker.delay_jobs = false
    end

    def reset!
      @collect = true
      @total_processed = 0
      @enabled = false

      Delayed::Job.delete_all
      Delayed::Worker.delay_jobs = true
    end

    def process_queue!
      success, failure = Delayed::Worker.new(
                 quiet: true # you might want to change this to false for debugging
               ).work_off
      @total_processed = success + failure
    end
  end
end
