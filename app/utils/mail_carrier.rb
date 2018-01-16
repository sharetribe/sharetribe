# settings MailJet
require 'mailjet'
Mailjet.configure do |config|
  config.api_key = APP_CONFIG.mailjet_user
  config.secret_key = APP_CONFIG.mailjet_password
  config.default_from = APP_CONFIG.mailjet_default_from
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
