require 'spec_helper'

describe EmailService::SES::Client do
  describe "#initialize" do
    it "requires fully specified config" do
      expect { EmailService::SES::Client.new(config: nil) }.to raise_error(StandardError)
      expect { EmailService::SES::Client.new(config: {region: "fake-region"}) }.to raise_error(ArgumentError)
      expect { EmailService::SES::Client.new(config: {access_key_id: "access_key", secret_access_key: "secret_access_key"}) }
        .to raise_error(ArgumentError)
      expect { EmailService::SES::Client.new(config: {region: "fake-region", access_key_id: "access_key", secret_access_key: "secret_access_key"}) }
        .to raise_error(ArgumentError)
      expect { EmailService::SES::Client.new(config: {region: "fake-region", access_key_id: "access_key", secret_access_key: "secret_access_key", sns_topic: "fake-sns-topic-arn"}) }
        .to_not raise_error
    end

    it "supports fake responses with stubbing" do
      stubs = {
        list_verified_email_addresses: {verified_email_addresses: ["foo@bar.com", "bar@foo.com"]}}
      ses_client = EmailService::SES::Client.new(config: {region: "fake-region", access_key_id: "access_key", secret_access_key: "secret_access_key", sns_topic: "fake-sns-topic-arn"},
                                                 stubs: stubs)

      expect(ses_client.list_verified_addresses()[:data])
        .to eq(["foo@bar.com", "bar@foo.com"])
      expect(ses_client.verify_address(email: "test@sharetribe.com"))
        .to eq(Result::Success.new)
    end

    it "supports stubbing error responses" do
      stubs = {
        list_verified_email_addresses: "Error",
        verify_email_identity: "Error"}
      ses_client = EmailService::SES::Client.new(config: {region: "fake-region", access_key_id: "access_key", secret_access_key: "secret_access_key", sns_topic: "fake-sns-topic-arn"},
                                                 stubs: stubs)

      expect(ses_client.list_verified_addresses().success).to eq(false)
      expect(ses_client.verify_address(email: "foo@bar.com").success).to eq(false)
    end
  end
end
