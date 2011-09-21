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
  config.action_view.debug_rjs             = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = true
  
  # As instructed by Devise, to make local mails work
  #config.action_mailer.default_url_options = { :host => 'test.lvh.me:3000' }
  
  # Enable sending mail from localhost
  ActionMailer::Base.smtp_settings = {
    :address              => APP_CONFIG.local_email_address,
    :port                 => APP_CONFIG.local_email_port,
    :domain               => 'localhost',
    :user_name            => APP_CONFIG.local_email_user_name,
    :password             => APP_CONFIG.local_email_password,
    :authentication       => 'plain',
    :enable_starttls_auto => true  
  }

  config.active_support.deprecation = :log
  
end
