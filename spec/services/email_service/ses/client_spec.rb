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
  end
end
