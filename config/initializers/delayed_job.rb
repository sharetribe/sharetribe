require 'delayed_job'
Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.max_attempts = 3
Delayed::Worker.max_run_time = 3.minutes # In order to recover from hanging DelayedDelta. Currently no jobs should be longer than 3min.

# Require custom delayed jobs that are accessed from migrations
require "#{Rails.root}/app/jobs/reprocess_listing_image_job"