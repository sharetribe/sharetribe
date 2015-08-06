module EmailService::API
  class Api

    def self.addresses
      @addresses ||= EmailService::API::Addresses.new(
        default_sender: "Default Sender Name <default_sender@example.com.invalid>")
    end
  end
end
