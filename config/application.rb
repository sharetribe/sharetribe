# encoding: UTF-8

require File.expand_path('../boot', __FILE__)

require 'rails/all'

# These needed to load the config.yml
require File.expand_path('../config_loader', __FILE__)


if defined?(Bundler)  
  # If you precompile assets before deploying to production, use this line  
  Bundler.require *Rails.groups(:assets => %w(development test))  
  # If you want your assets lazily compiled in production, use this line  
  # Bundler.require(:default, :assets, Rails.env)  
end



module Kassi
  class Application < Rails::Application
    # Load all rack middleware files
    config.autoload_paths += %W(#{config.root}/lib/rack_middleware)
    
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
    
    # Define here additional Assset Pipeline Manifests to include to precompilation
    config.assets.precompile += ['dashboard.js', 'dashboard.css', 'markerclusterer.js', 'communities/custom-style-*', 'ss-*','old_ie.css', 'html5shiv-printshiv.js', 'mercury.js','jquery-1.7.js']
    
    # Read the config from the config.yml 
    APP_CONFIG = load_app_config

    # enable custom domain cookies rack middleware
    config.middleware.use "CustomDomainCookie", APP_CONFIG.domain
        
    # This is the list of all possible locales. Part of the translations may be unfinished.
    config.AVAILABLE_LOCALES = [
          ["English", "en"], 
          ["Suomi", "fi"], 
          ["Pусский", "ru"], 
          ["Nederlands", "nl"], 
          ["Ελληνικά", "el"], 
          ["Kiswahili", "sw"], 
          ["Română", "ro"], 
          ["Français", "fr"], 
          ["中文", "zh"], 
          ["Español", "es"], 
          ["Español", "es-ES"], 
          ["Catalan", "ca"],
          ["Tiếng Việt", "vi"],
          ["Deutsch", "de"],
          ["Svenska", "sv"],
          ["Italiano", "it"],
          
          # Customization languages
          ["English", "en-rc"],
          ["Français", "fr-rc"],
          ["Español", "es-rc"],
          ["Deutsch", "de-rc"],
          
          ["English UL", "en-ul"],

          ["English SB", "en-sb"],
          
    ]

    # This is the list o locales avaible for the dashboard and newly created tribes in UI
    config.AVAILABLE_DASHBOARD_LOCALES = [
          ["English", "en"], 
          ["Suomi", "fi"],
          ["Español", "es"],
          ["Français", "fr"],
          ["Deutsch", "de"],
          ["Pусский", "ru"], 
          ["Ελληνικά", "el"]
    ]
    
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
    
    # If logger_type is set to something else than "normal" we'll use stdout here
    # the reason for this type of check is that it works also in Heroku where those variables can't be read in slug compilation
    if (Rails.env.production? || Rails.env.staging?) && APP_CONFIG.logger_type != "normal"
      # Set the logger to STDOUT, based on tip at: http://blog.codeship.io/2012/05/06/Unicorn-on-Heroku.html
      # For unicorn logging to work
      # It looks stupid that this is not in production.rb, but according to that blog,
      # it needs to be set here to work
      config.logger = Logger.new(STDOUT)
      config.logger.level = Logger.const_get(ENV['LOG_LEVEL'] ? ENV['LOG_LEVEL'].upcase : 'INFO')
    end
    
    config.to_prepare do
      Devise::Mailer.layout "email" # email.haml or email.erb
      Devise::Mailer.helper :email_template
    end

  end
end
