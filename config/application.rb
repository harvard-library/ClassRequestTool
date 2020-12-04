require_relative 'boot'

require 'rails/all'
require 'open3'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)
Dotenv::Railtie.load   # bring in .env early enough for the config/ files to be able to handle it.

module ClassRequestTool
  class Application < Rails::Application

    # Set rspec as default testing platform
    config.generators do |g|
      g.test_framework :rspec
    end
    
    # Use delayed_job as the queueing backend
    config.active_job.queue_adapter = :delayed_job   
    
    # deal with ugly IE compatibility mode issues:
    config.action_dispatch.default_headers.merge!({
        'X-UA-Compatible' => 'IE=edge,chrome=1'
    })
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    config.autoloader = :classic
    
    # Settings in config/environments/* take precedence over those specified here.
    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Eastern Time (US & Canada)'

    

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true
    crt_reports_config = YAML::load(File.open("#{Rails.root}/config/reports.yml")).symbolize_keys
    if crt_reports_config
      config.crt_reports = crt_reports_config
    end
    
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # since this app is upgraded from a previous version, opt out of belongs_to being required by default
    config.active_record.belongs_to_required_by_default = false

  end
end
