# Be sure to restart your server when you modify this file.

Rails.application.config.session_store :cookie_store, :key => '_kassi_session', :domain => APP_CONFIG.domain, :expire_after => 20.days

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# Rails.application.config.session_store :active_record_store
