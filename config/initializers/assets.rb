# Enable the asset pipeline and bower
Rails.application.config.assets.enabled = true
# Be sure to restart your server when you modify this file.

Rails.root.join('vendor', 'assets', 'bower_components').to_s.tap do |bower_path|
  Rails.application.config.assets.paths << bower_path

  # icheck images
  Rails.application.config.assets.paths << "#{bower_path}/icheck/skins/square/"
end

# Minimum Sass number precision required by bootstrap-sass
::Sass::Script::Value::Number.precision = [8, ::Sass::Script::Value::Number.precision].max

# Version of your assets, change this if you want to expire all your assets
Rails.application.config.assets.version = '1.0'

# Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
Rails.application.config.assets.precompile += %w( ckeditor/* )
Rails.application.config.assets.precompile += %w( iefix.css )
Rails.application.config.assets.precompile += %w( application_split2_ie.css )
  # Add color chips for icheck (managed with bower)
Rails.application.config.assets.precompile += %w( icheck/skins/square/blue.png icheck/skins/square/blue@2x.png )


# Enable serving of images, stylesheets, and JavaScripts from an asset server
# Rails.application.config.action_controller.asset_host = "http://assets.example.com"

# Generate digests for assets URLs
Rails.application.config.assets.digest = true

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << Rails.root.join('node_modules')

# Expire assets
Rails.application.config.assets.expire_after 2.weeks
# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
# Rails.application.config.assets.precompile += %w( admin.js admin.css )
