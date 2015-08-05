module EmailService::EmailServiceInjector
  def addresses_api
    @addresses = EmailService::API::Addresses.new(
      default_sender: APP_CONFIG.sharetribe_mail_from_address
    )
  end
end
