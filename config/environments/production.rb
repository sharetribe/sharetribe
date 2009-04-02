# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true
config.action_view.cache_template_loading            = true

# Use a different cache store in production
# config.cache_store = :mem_cache_store

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host                  = "http://assets.example.com"

# Environment variables specific for production version
# these are specified here for alpha, but changed to fit for beta in beta-finish.sh
COS_URL = "http://cos.alpha.sizl.org"
COS_URL_PROXIED = "http://kassi.alpha.sizl.org/cos"

config.action_mailer.raise_delivery_errors = true
config.action_mailer.delivery_method = :sendmail
ActionMailer::Base.sendmail_settings = {
  :location       => '/usr/sbin/sendmail',
  :arguments      => '-i -t'
}
ActionMailer::Base.perform_deliveries = true # the "deliver_*" methods are available
ActionMailer::Base.default_charset = "utf-8"