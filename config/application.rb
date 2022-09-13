# encoding: utf-8

require_relative 'boot'

require 'rails/all'

# These needed to load the config.yml
require File.expand_path('../config_loader', __FILE__)

require File.expand_path('../available_locales', __FILE__)

require File.expand_path('../facebook_sdk_version', __FILE__)

# Load the logger
require File.expand_path('../../lib/sharetribe_logger', __FILE__)

# Load the deprecator
require File.expand_path('../../lib/method_deprecator', __FILE__)

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# Require Transit. This needs to be done manually, because the gem name
# (transit-ruby) doesn't match to the module name (Transit) and that's
# why Bundler doesn't know how to autoload it
require 'transit'


require File.expand_path('../../lib/sharetribe_middleware', __FILE__)

module Kassi
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    # and thus class const
    config.load_defaults 5.1
    config.active_record.belongs_to_required_by_default = false

    # This is a little cubersome, but this needs to be shared with the StylesheetCompiler,
    # and thus class const
    VENDOR_CSS_PATH = Rails.root.join("vendor", "assets", "stylesheets")

    # Load all rack middleware files
    config.autoload_paths += %W(#{config.root}/lib/rack_middleware)

    # Load models from subdirectories too
    config.autoload_paths += Dir[Rails.root.join('app', 'models', '**/')]
    config.autoload_paths += Dir[Rails.root.join('app', 'services')]
    config.autoload_paths += Dir[Rails.root.join('app', 'utils')]
    config.autoload_paths += Dir[Rails.root.join('app', 'view_utils')]
    config.autoload_paths += Dir[Rails.root.join('app', 'forms')]
    config.autoload_paths += Dir[Rails.root.join('app', 'validators')]

    # Fakepal
    config.autoload_paths += Dir[Rails.root.join('lib', 'services')]

    # Load also Jobs that are used by migrations
    config.autoload_paths += Dir[Rails.root.join('db', 'migrate_jobs', '**/')]

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    # From http://guides.rubyonrails.org/asset_pipeline.html#precompiling-assets
    # For faster asset precompiles, you can partially load your application by setting
    # config.assets.initialize_on_precompile to false in config/application.rb, though
    # in that case templates cannot see application objects or methods.
    # Heroku requires this to be false.
    config.assets.initialize_on_precompile = false

    # Add webfonts folder which can contain icons used like fonts
    config.assets.paths << Rails.root.join("app", "assets", "webfonts")
    config.assets.paths << VENDOR_CSS_PATH

    # Define here additional Asset Pipeline Manifests to include to precompilation
    config.assets.precompile += [
      'markerclusterer.js',
      'communities/custom-style-*',
      'ss-*',
      'modernizr.min.js',
      'mercury.js',
      'jquery-1.7.js',
      'i18n/*.js',
      'app-bundle.css',
      'app-bundle.js',
      'vendor-bundle.js',
    ]

    # Read the config from the config.yml
    APP_CONFIG = ConfigLoader.load_app_config

    #Disable ip spoofing check to get rid of false alarms because of wrong configs in some proxies before our service
    #Consider enabling, and other actions described in http://blog.gingerlime.com/2012/rails-ip-spoofing-vulnerabilities-and-protection
    config.action_dispatch.ip_spoofing_check = false
    config.action_dispatch.trusted_proxies = APP_CONFIG.trusted_proxies&.split(",")&.map(&:strip)

    if APP_CONFIG.use_rack_attack.to_s.casecmp("true").zero?
      # Rack attack middleware for throttling and blocking unwanted traffic
      config.middleware.insert_after ActionDispatch::RemoteIp, Rack::Attack
    end

    # HealthCheck endpoint
    config.middleware.insert_before Rack::Sendfile, ::HealthCheck

    # Manually redirect http to https, if config option always_use_ssl is set to true
    # This needs to be done before routing: conditional routes break if this is done later
    # Enabling HSTS and secure cookies is not a possiblity because of potential reuse of domains without HTTPS
    config.middleware.insert_before Rack::Sendfile, ::EnforceSsl

    # Handle cookies with old key
    config.middleware.use Rack::MethodOverride

    config.middleware.insert_before ActionDispatch::Cookies, ::CustomCookieRenamer

    # Resolve current marketplace and append it to env
    config.middleware.use ::MarketplaceLookup
    config.middleware.use ::SessionContextMiddleware

    # Map of removed locales and their fallbacks
    config.REMOVED_LOCALE_FALLBACKS = Sharetribe::REMOVED_LOCALE_FALLBACKS

    # List of removed locales
    config.REMOVED_LOCALES = Sharetribe::REMOVED_LOCALES

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Add additional load paths for your own custom dirs
    # config.load_paths += %W( #{config.root}/extras )

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = (APP_CONFIG.default_locale ? APP_CONFIG.default_locale.to_sym : :en)

    # add locales from subdirectories
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]

    # Speed up schema loading. No need to use rake when creating database schema
    # from SQL dump.
    config.active_record.schema_format = :sql

    # Configure generators values. Many other options are available, be sure to check the documentation.
    # config.generators do |g|
    #   g.orm             :active_record
    #   g.template_engine :erb
    #   g.test_framework  :test_unit, :fixture => true
    # end

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # ActiveRecord should be in UTC timezone.
    config.time_zone = 'UTC'

    # Configure Paperclip
    paperclip_options = {
          :path => ":rails_root/public/system/:attachment/:id/:style/:filename",
          :url => "/system/:attachment/:id/:style/:filename"
    }

    if APP_CONFIG.user_asset_host
      paperclip_options[:url] = "#{APP_CONFIG.user_asset_host}#{paperclip_options[:url]}"
    end

    if (APP_CONFIG.s3_bucket_name && APP_CONFIG.aws_access_key_id && APP_CONFIG.aws_secret_access_key)
      # S3 is in use for uploaded images
      s3_domain = "amazonaws.com"
      # us-east-1 has special S3 endpoint, see http://docs.aws.amazon.com/general/latest/gr/rande.html#s3_region
      s3_host_name = if APP_CONFIG.s3_region == "us-east-1"
                       "s3.#{s3_domain}"
                     else
                       "s3-#{APP_CONFIG.s3_region}.#{s3_domain}"
                     end
      paperclip_options.merge!({
        :path => "images/:class/:attachment/:id/:style/:filename",
        :url => ":s3_domain_url",
        :storage => :s3,
        :s3_region => APP_CONFIG.s3_region,
        :s3_protocol => 'https',
        :s3_host_name => s3_host_name,
        :s3_headers => {
            "cache-control" => "public, max-age=#{APP_CONFIG.s3_cache_max_age}",
            "expires" => APP_CONFIG.s3_cache_max_age.to_i.seconds.from_now.httpdate,
        },
        :s3_credentials => {
              :bucket            => APP_CONFIG.s3_bucket_name,
              :access_key_id     => APP_CONFIG.aws_access_key_id,
              :secret_access_key => APP_CONFIG.aws_secret_access_key
        }
      })

      if APP_CONFIG.user_asset_host
        # CDN in use in front of S3
        _, assets_proto, assets_host = *APP_CONFIG.user_asset_host.match(/^(https?):\/\/(.*)$/)

        paperclip_options.merge!({
          :s3_host_alias => assets_host,
          :s3_protocol => assets_proto,
          :url => ":s3_alias_url",
        })
      end
    end
    config.paperclip_defaults = paperclip_options

    config.to_prepare do
      Devise::Mailer.layout "email" # email.haml or email.erb
      Devise::Mailer.helper :email_template
    end

    # Log deprecation warnings to stderr
    config.active_support.deprecation = :stderr

    # Map custom errors to error pages
    config.action_dispatch.rescue_responses["PeopleController::PersonDeleted"] = :gone
    config.action_dispatch.rescue_responses["PeopleController::PersonBanned"] = :gone
    config.action_dispatch.rescue_responses["ListingsController::ListingDeleted"] = :gone
    config.action_dispatch.rescue_responses["ApplicationController::FeatureFlagNotEnabledError"] = :not_found

    config.exceptions_app = self.routes

    config.active_job.queue_adapter = :delayed_job

    # TODO remove deprecation warnings when removing legacy analytics
    ActiveSupport::Deprecation.warn("Support for Kissmetrics is deprecated, please use Google Tag Manager instead") if APP_CONFIG.use_kissmetrics.to_s == "true"
    ActiveSupport::Deprecation.warn("Support for Google Analytics is deprecated, please use Google Tag Manager instead") if APP_CONFIG.use_google_analytics.to_s == "true"

    config.after_initialize do
      require File.expand_path('../../lib/active_storage_decorator', __FILE__)
    end
  end
end
