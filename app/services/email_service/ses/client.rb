module EmailService::SES
  class Client

    def initialize(region:, stubs: nil)
      if region.blank?
        raise ArgumentError.new("Missing mandatory value for region parameter.")
      end

      # The SDK v2 automatically gets the AWS_ACCESS_KEY and
      # AWS_SECRET_ACCESS_KEY from the environment. We only need to
      # supply region here.
      if stubs.blank?
        @ses = Aws::SES::Client.new(region: region)
      else
        @ses = Aws::SES::Client.new(region: region, stub_responses: stubs)
      end
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

  end
end
