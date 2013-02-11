require 'delayed_job'
Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.max_attempts = 3