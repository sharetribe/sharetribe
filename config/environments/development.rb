Kassi::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = true
  
  # Enable sending mail from localhost
  # ActionMailer::Base.smtp_settings = {
  #   :address              => APP_CONFIG.smtp_email_address,
  #   :port                 => APP_CONFIG.smtp_email_port,
  #   :domain               => 'localhost',
  #   :user_name            => APP_CONFIG.smtp_email_user_name,
  #   :password             => APP_CONFIG.smtp_email_password,
  #   :authentication       => 'plain',
  #   :enable_starttls_auto => true  
  # }

  config.active_support.deprecation = :log
  
  # Do not compress assets  
  config.assets.compress = false  

  # Expands the lines which load the assets  
  config.assets.debug = false
  
  # Raise exception on mass assignment protection for Active Record models
  config.active_record.mass_assignment_sanitizer = :strict

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  config.active_record.auto_explain_threshold_in_seconds = 0.5
  
end
