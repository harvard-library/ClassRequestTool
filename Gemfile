source 'https://rubygems.org'

gem 'dotenv-rails'
gem 'rails', '>= 4.1'
gem 'sprockets-rails', :require => 'sprockets/railtie'
gem 'stackprof'                  # For ruby 2.1
gem 'therubyracer'
gem 'devise'
gem 'formtastic'
gem 'formtastic-bootstrap'
gem 'will_paginate'
gem 'pg'
gem 'postgres_ext'
gem 'carrierwave'
gem 'descriptive_statistics', :require => 'descriptive_statistics/safe'
gem 'mini_magick'
gem 'delayed_job_active_record'
gem 'daemons'
gem 'ckeditor'
gem 'devise_harvard_auth_proxy', :git => 'https://github.com/harvard-library/devise_harvard_auth_proxy.git'
gem 'css_splitter'
gem 'haml-rails'
gem 'bower-rails'
gem 'cocoon'
gem 'bootstrap-sass'
gem 'sass-rails'
gem 'uglifier'

group :test, :development do
  gem 'rspec-rails'
  gem 'stepford'
  gem 'pry-rails'
  gem 'pry-remote'
  gem 'pry-doc'
  gem 'pry-byebug'
end

group :test do
  gem 'factory_girl_rails'
  gem 'cucumber-rails', :require => false
  gem 'database_cleaner'
  gem 'schema_to_scaffold'
end

group :development do
  gem 'capistrano',        '~> 3.1'
  gem 'capistrano-rails',  '~> 1.1'
  gem 'capistrano-rvm'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'puma'

  # Performance analysis
  gem 'bullet'
  gem 'rack-mini-profiler', require: false
  gem 'flamegraph'
end
