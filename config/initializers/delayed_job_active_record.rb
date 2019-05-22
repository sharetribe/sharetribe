# https://github.com/collectiveidea/delayed_job_active_record/issues/63
Delayed::Backend::ActiveRecord.configure do |config|
  config.reserve_sql_strategy = :default_sql
end

# workaround based on https://github.com/collectiveidea/delayed_job_active_record/pull/91
module Delayed
  module Backend
    module ActiveRecord
      class Job < ::ActiveRecord::Base
        def save(*)
          retries = 0

          begin
            super
          rescue ::ActiveRecord::Deadlocked => e
            if retries < 10
              logger.info "ActiveRecord::Deadlocked rescued: #{e.message}"
              logger.info 'Retrying...'

              retries += 1
              retry
            else
              raise
            end
          end
        end
      end
    end
  end
end
