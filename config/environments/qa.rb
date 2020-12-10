Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  config.cache_classes = true

  # Do not eager load code on boot. This avoids loading your whole application
  # just for the purpose of running a single test. If you are using a tool that
  # preloads Rails for running tests, you may have to set it to true.
  config.eager_load = true

  # Configure public file server with Cache-Control for performance.
  config.public_file_server.enabled = true
  config.public_file_server.headers = {
    'Cache-Control' => "public, max-age=#{1.hour.to_i}"
  }

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  #config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment.
  #config.action_controller.allow_forgery_protection = false
  
  config.active_storage.service = :local

  # Use the lowest log level to ensure availability of diagnostic information when problems arise.
  config.log_level = :debug

  config.action_mailer.perform_caching = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :smtp

  config.action_mailer.smtp_settings = {
    address:              ENV['SMTP_ADDRESS'],
    port:                 ENV['SMTP_PORT'],
    domain:               ENV['SMTP_DOMAIN'],
    username:             ENV['SMTP_USERNAME']||'',
    password:             ENV['SMTP_PASSWORD']||'',
    authentication:       ENV['SMTP_AUTHENTICATION']||:plain,
    enable_starttls_auto: ENV['SMTP_TLS']||false
  }

  MAIL_RECIPIENT_OVERRIDE = (ENV['OVERRIDE_RECIPIENTS']||[]).split(",")
  config.action_mailer.perform_caching = false

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  # Use a different logger for distributed setups.
  # require 'syslog/logger'
  # config.logger = ActiveSupport::TaggedLogging.new(Syslog::Logger.new 'app-name')

  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger           = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger    = ActiveSupport::TaggedLogging.new(logger)
  end

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

end
