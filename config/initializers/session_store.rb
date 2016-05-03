# Be sure to restart your server when you modify this file.

Rails.application.config.session_store :active_record_store, :key => APP_CONFIG.cookie_session_key, :expire_after => 1.month

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# Rails.application.config.session_store :active_record_store
