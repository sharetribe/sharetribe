require File.expand_path('../boot', __FILE__)

require 'rails/all'

# These needed to load the config.yml
require 'yaml'
require 'ostruct'


# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env) if defined?(Bundler)



module Kassi
  class Application < Rails::Application
    
    # Read the config from the config.yml # THIS SHOULD BE DONE IN load_config.yml, but for some reason APP_CONFIG is not usable here
    APP_CONFIG = OpenStruct.new(YAML.load_file("#{Rails.root}/config/config.yml")[Rails.env].symbolize_keys)
    
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
    config.i18n.default_locale = APP_CONFIG.default_locale.to_sym

    # Configure generators values. Many other options are available, be sure to check the documentation.
    # config.generators do |g|
    #   g.orm             :active_record
    #   g.template_engine :erb
    #   g.test_framework  :test_unit, :fixture => true
    # end

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]
    
    config.time_zone = 'Helsinki'
    if APP_CONFIG.use_recaptcha
      ENV['RECAPTCHA_PUBLIC_KEY']  = APP_CONFIG.recaptcha_public_key
      ENV['RECAPTCHA_PRIVATE_KEY'] = APP_CONFIG.recaptcha_private_key
    end

  end
end
