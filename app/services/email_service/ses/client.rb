module EmailService::SES
  module DataTypes
    Config = EntityUtils.define_builder(
      [:region, :mandatory, :string],
      [:access_key_id, :mandatory, :string],
      [:secret_access_key, :mandatory, :string],
      [:sns_topic, :mandatory, :string])

    NotificationTopic = EntityUtils.define_builder(
      [:email, :mandatory, :string],
      [:type, one_of: [:bounce, :complaint]])
  end

  class Client

    def initialize(config:, stubs: nil)
      config = DataTypes::Config.build(config)

      if stubs.blank?
        @ses = Aws::SES::Client.new(config.except(:sns_topic))
      else
        @ses = Aws::SES::Client.new(config.except(:sns_topic).merge(stub_responses: stubs))
      end

      @sns_topic = config[:sns_topic]
    end

    def list_verified_addresses
      begin
        response = @ses.list_verified_email_addresses
        if response.successful?
          Result::Success.new(response.verified_email_addresses)
        else
          Result::Error.new(response.error)
        end
      rescue StandardError => e
        Result::Error.new(e)
      end
    end

    # Request verification for the given email address. If called
    # twice with the same address resends the verification email.
    def verify_address(email: )
      if email.blank?
        raise ArgumentError.new("Missing mandatory value for email parameter.")
      end

      begin
        response = @ses.verify_email_identity(email_address: email)
        if response.successful?
          Result::Success.new()
        else
          Result::Error.new(response.error)
        end
      rescue StandardError => e
        Result::Error.new(e)
      end
    end

    def set_notification_topic(email:, type:)
      unless @sns_topic
        raise ArgumentError.new("@sns_topic must be set")
      end

      nt = DataTypes::NotificationTopic.call({email: email, type: type})

      begin
        response = @ses.set_identity_notification_topic(
          {identity: nt[:email],
           notification_type: nt[:type].to_s.capitalize,
           sns_topic: @sns_topic})

        if response.successful?
          Result::Success.new()
        else
          Result::Error.new(response.error)
        end
      rescue StandardError => e
        Result::Error.new(e)
      end
    end

  end
end
