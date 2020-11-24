require 'delayed_job'

class DelayedJobLoggerPlugin < Delayed::Plugin

  callbacks do |lifecycle|

    lifecycle.around(:invoke_job) do |job, &block|
      logger.info "Running job", :running, job_to_hash(job)
      begin
        block.call(job)
        logger.info "Job success", :success, job_to_hash(job)
      rescue Exception => e
        # log and reraise
        logger.info "Job error: #{e.inspect}", :error, job_to_hash(job)
        raise e
      end
    end
  end

  def self.job_to_hash(job)
    payload = job.payload_object # Usually the Struct, but can be a PerformableObject also

    case payload
    when Struct
      {job_name: payload.class.name, args: payload.to_h }
    when Delayed::PerformableMethod
      {job_name: "#{payload.object.to_s}.#{payload.method_name.to_s}", args: payload.args.to_s}
    else
      {payload: payload.inspect}
    end
  end

  def self.logger
    @logger ||= SharetribeLogger.new(:delayed_job)
  end
end

module Delayed
  module Plugins
    class RequestStorePlugin < Plugin
      callbacks do |lifecycle|
        lifecycle.after(:invoke_job) do |job|
          RequestStore.clear!
        end
      end
    end
  end
end

Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.max_attempts = 3
Delayed::Worker.max_run_time = APP_CONFIG.delayed_job_max_run_time.to_i.seconds
Delayed::Worker.default_priority = 5
Delayed::Worker.default_queue_name = "default"
Delayed::Worker.plugins << DelayedJobLoggerPlugin
Delayed::Worker.plugins << Delayed::Plugins::RequestStorePlugin
