ClassRequestTool::Application.configure do

  #** Removed for Rails 4
  #++ Added for Rails 4 
  
  #++
  config.eager_load = false

  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  #** config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Set up action mailer
  mailer_data = ERB.new File.new("#{Rails.root}/config/mailer.yml.erb").read
  mailer_config = YAML::load(mailer_data.result(binding))
  config.action_mailer.raise_delivery_errors = true
  mailconf = mailer_config[:mailer][:development]
  config.action_mailer.delivery_method = mailconf[:delivery_method]
  config.action_mailer.smtp_settings = mailconf[:settings].clone
  config.action_mailer.default_url_options = { :protocol => 'http://', :host => mailconf[:settings][:domain], :port => ':3000' }

  MAIL_RECIPIENT_OVERRIDE = ['tim@wordsareimages.com','kinnel@warpmail.net']
  
  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log
  
  # Report DB errors
  config.active_record.raise_in_transactional_callbacks = true

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Raise exception on mass assignment protection for Active Record models
  #** config.active_record.mass_assignment_sanitizer = :strict

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  #**config.active_record.auto_explain_threshold_in_seconds = 0.5

  # Do not compress assets
  config.assets.compress = false
  
  #** config.assets.raise_runtime_errors = true

  # Expands the lines which load the assets
  config.assets.debug = true
  
  BetterErrors::Middleware.allow_ip! '127.0.0.1' 

  config.after_initialize do
    Bullet.enable = true
    Bullet.bullet_logger = true
    Bullet.console = true
    
    # Turned off
    Bullet.growl = false
    Bullet.xmpp = false
    Bullet.rails_logger = false
    Bullet.bugsnag = false
    Bullet.airbrake = false
    Bullet.add_footer = true
    Bullet.stacktrace_includes = false
  end
end

