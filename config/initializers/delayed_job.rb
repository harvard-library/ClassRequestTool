Delayed::Worker.destroy_failed_jobs = false if Rails.env.development?
Delayed::Worker.logger = Logger.new(Rails.root.join('log', 'delayed_job.log'))
