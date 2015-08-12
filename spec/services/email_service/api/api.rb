module EmailService::API
  class Api

    def self.ses_client
      EmailService::SES::Client.new(
        config: {
          region: "fake-region",
          access_key_id: "access_key",
          secret_access_key: "secret_access_key",
          sns_topic: "fake-sns-topic-arn"},
        stubs: true)
    end

    def self.addresses
      @addresses ||= EmailService::API::Addresses.new(
        default_sender: "Default Sender Name <default_sender@example.com.invalid>")
    end
  end
end
