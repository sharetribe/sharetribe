require 'delayed_job'
Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.max_attempts = 3
Delayed::Worker.max_run_time = 3.minutes # In order to recover from hanging DelayedDelta. Currently no jobs should be longer than 3min.
Delayed::Worker.default_priority = 5