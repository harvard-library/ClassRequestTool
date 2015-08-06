ClassRequestTool::Application.configure do
  #++ Added for Rails 4 
  config.eager_load = true

  # Settings specified here will take precedence over those in config/application.rb

  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_files = false

  # Compress JavaScripts and CSS
  config.assets.compress = true

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = true

  # Scan application.scss for css files and application.js for js files to precompile
  precompile_array = []
  css = File.readlines(Rails.root.join('app', 'assets', 'stylesheets', 'application.scss'))
  css.each do |line|
    asset = /^@import\s+["'](.+)["']/.match(line)
    precompile_array << (asset[1].split('/').pop) + '.css' unless asset.nil? 
  end
  js = File.readlines(Rails.root.join('app', 'assets', 'javascripts', 'application.js'))
  js.each do |line|
    asset = /^\/\/=\s+require\s+(.+)/.match(line)
    precompile_array << (asset[1].split('/').pop) + '.js' unless asset.nil? 
  end
  config.assets.precompile += precompile_array
  #  config.assets.precompile += %w( jquery.qtip.css application_split2_ie.css iefix.css jquery-ui-timepicker-addon.css jquery-ui-timepicker-addon.js icheck.js icheck.scss jquery.tablesorter.pager.css filter.formatter.css)

  # Precompile Bootstrap fonts
  config.assets.precompile << %r(bootstrap-sass/assets/fonts/bootstrap/[\w-]+\.(?:eot|svg|ttf|woff2?)$)

  # Generate digests for assets URLs
  config.assets.digest = true

  # Defaults to nil and saved in location specified by config.assets.prefix
  # config.assets.manifest = YOUR_PATH

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Prepend all log lines with the following tags
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  # config.assets.precompile += %w( search.js )

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false
  
  # Set up action mailer
  mailer_config = YAML::load(File.open("#{Rails.root}/config/mailer.yml"))
  config.action_mailer.raise_delivery_errors = true
  mailconf = mailer_config[:mailer][:production]
  config.action_mailer.delivery_method = mailconf[:delivery_method]
  config.action_mailer.smtp_settings = mailconf[:settings].clone
  config.action_mailer.default_url_options = { :protocol => 'http://', :host => mailconf[:settings][:domain] }

    
  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

end
