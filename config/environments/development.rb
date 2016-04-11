require_relative './common.rb'

Kassi::Application.configure do
  APP_CONFIG ||= ConfigLoader.load_app_config

  # Settings specified here will take precedence over those in config/environment.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # To autoload MailPreview, uncomment this line
  # (this is a hack which is fixed properly in Rails 4)
  # config.action_view.cache_template_loading = false

  config.log_level = :debug

  # Basic log config, for calls to Rails.logger.<level> { <message> }
  config.logger = ::Logger.new(STDOUT)
  # Formats log entries into: LEVEL MESSAGE
  # Heroku adds to this timestamp and worker/dyno id, so datetime can be stripped
  config.logger.formatter = ->(severity, datetime, progname, msg) { "#{severity} #{msg}\n" }

  # Lograge config, overrides default instrumentation for logging ActionController and ActionView logging
  config.lograge.enabled = true
  config.lograge.custom_options = ->(event) {
    params = event.payload[:params].except('controller', 'action')

    { params: params,
      host: event.payload[:host],
      community_id: event.payload[:community_id],
      current_user_id: event.payload[:current_user_id],
      request_uuid: event.payload[:request_uuid] }
  }

  config.lograge.formatter = Lograge::Formatters::Json.new

  config.after_initialize do
    ActiveRecord::Base.logger = Rails.logger.clone
    ActiveRecord::Base.logger.level = Logger::DEBUG
    ActionMailer::Base.logger = Rails.logger.clone
    ActionMailer::Base.logger.level = Logger::INFO
  end



  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  config.action_controller.action_on_unpermitted_parameters = :raise

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  if APP_CONFIG.mail_delivery_method == "sendmail"
    ActionMailer::Base.delivery_method = :sendmail
  elsif APP_CONFIG.mail_delivery_method == "smtp"
    # Enable sending mail from localhost
    ActionMailer::Base.smtp_settings = {
      :address              => APP_CONFIG.smtp_email_address,
      :port                 => APP_CONFIG.smtp_email_port,
      :domain               => APP_CONFIG.smtp_email_domain || 'localhost',
      :user_name            => APP_CONFIG.smtp_email_user_name,
      :password             => APP_CONFIG.smtp_email_password,
      :authentication       => 'plain',
      :enable_starttls_auto => true
    }
  end


  # Expands the lines which load the assets
  config.assets.debug = false

  # Raise exception on mass assignment protection for Active Record models
  config.active_record.mass_assignment_sanitizer = :strict

  config.cache_store = :memory_store, { :namespace => "sharetribe-dev"}
end
