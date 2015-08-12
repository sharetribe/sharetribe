module EmailService::EmailServiceInjector
  def addresses_api
    @addresses ||= build_addresses_api()
  end

  def ses_client_instance
    @ses_client ||= build_ses_client()
  end

  def build_addresses_api
    EmailService::API::Addresses.new(
      default_sender: APP_CONFIG.sharetribe_mail_from_address,
      ses_client: build_ses_client()
    )
  end

  def build_ses_client
    if APP_CONFIG.aws_ses_region &&
       APP_CONFIG.aws_access_key_id &&
       APP_CONFIG.aws_secret_access_key
      EmailService::SES::Client.new(
        config: { region: APP_CONFIG.aws_ses_region,
                  access_key_id: APP_CONFIG.aws_access_key_id,
                  secret_access_key: APP_CONFIG.aws_secret_access_key,
                  sns_topic: APP_CONFIG.aws_ses_sns_topic})
    else
      nil
    end
  end
end
