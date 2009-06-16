# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
# RAILS_GEM_VERSION = '2.1.0' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

require 'casclient'
require 'casclient/frameworks/rails/filter'
#require 'casclient/frameworks/rails/cas_proxy_callback_controller'

# enable detailed CAS logging for easier troubleshooting
cas_logger = CASClient::Logger.new(RAILS_ROOT+'/log/cas.log')
cas_logger.level = Logger::DEBUG

CASClient::Frameworks::Rails::Filter.configure(
    :cas_base_url => "http://alpha.sizl.org:8180/cas",
    :logger => cas_logger
 #   :proxy_retrieval_url => "https://kassi:3444/cas_proxy_callback/retrieve_pgt",
 #   :proxy_callback_url => "https://kassi:3444/cas_proxy_callback/receive_pgt"
)

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  # See Rails::Configuration for more options.

  # Skip frameworks you're not going to use. To use Rails without a database
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Specify gems that this application depends on. 
  # They can then be installed with "rake gems:install" on new installations.
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "aws-s3", :lib => "aws/s3"
  config.gem "ruby-prof"

  # Only load the plugins named here, in the order given. By default, all plugins 
  # in vendor/plugins are loaded in alphabetical order.
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Make Time.zone default to the specified zone, and make Active Record store time values
  # in the database in UTC, and return them converted to the specified local zone.
  # Run "rake -D time" for a list of tasks for finding time zone names. Uncomment to use default local time.
  config.time_zone = 'UTC'
  
  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  config.i18n.default_locale = :fi

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random, 
  # no regular words or you'll be exposed to dictionary attacks.
  config.action_controller.session = {
    :session_key => '_kassi_session',
    :secret      => '7ed9ea4fe15db6071aed42f1666fef83e9247981b7ea8efb251ab1d37c32e5cd8e6b3221cd1254f0baaa3d32d0ea0daaad187e8b663ae38b8e25ee1cdb231b81'
  }

  # Use the database for sessions instead of the cookie-based default,
  # which shouldn't be used to store highly confidential information
  # (create the session table with "rake db:sessions:create")
  # config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector
   
   #environment variables
   PURSE_LIMIT = -10
   
   #COS_URL is different in production env
   

   COS_URL = "http://maps.cs.hut.fi/cos"
   #COS_URL = "http://localhost:3001"
   #COS_URL = "http://cos.alpha.sizl.org"
   
   COS_URL_PROXIED = COS_URL #this won't work completely in develpment mode
  #For example there will be no confirmation when adding profile avatar picture

   COS_TIMEOUT = 15
   BETA_VERSION = "local"
   BUILT_AT = Time.now
   
   KASSI_MAIL_FROM_ADRESS = "kassi@sizl.org"
   PRODUCTION_SERVER = "local"
   

end


