Delayed::Worker.destroy_failed_jobs = false if !Rails.env.production?
Delayed::Worker.logger = Logger.new(Rails.root.join('log', 'delayed_job.log'))
Delayed::Worker.sleep_delay = Rails.env.production? ? 60 : 10
Delayed::Worker.max_attempts = 3
Delayed::Worker.max_run_time = 5.minutes
Delayed::Worker.read_ahead = 10
