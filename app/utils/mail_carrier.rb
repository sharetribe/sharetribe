# These needed to load the config.yml
require File.expand_path('/var/rails/sharetribe/config/config_loader', __FILE__)
# Read the config from the config.yml
APP_CONFIG = ConfigLoader.load_app_config
# settings MailJet
require '/usr/local/lib/ruby/gems/2.3.0/gems/mailjet-1.5.4/lib/mailjet.rb'
Mailjet.configure do |config|
  config.api_key = APP_CONFIG.mailjet_user
  config.secret_key = APP_CONFIG.mailjet_password
  config.default_from = APP_CONFIG.mailjet_from_email
end

module MailCarrier

  module_function

  # This is just a placeholder. Delivering later
  # hasn't been implemented you.
  def deliver_later(message)
    deliver_now(message)
  end

  def deliver_now(message)
    # Using MailJet
    variable = Mailjet::Send.create(
      from_email: APP_CONFIG.mailjet_from_email,
      from_name: APP_CONFIG.mailjet_from_name,
      subject: message.subject,
      text_part: '',
      html_part: message.decoded,
      recipients: [{ 'Email' => message.to }]
    )
    # Default not using
    #message.deliver_now
  end

end
