module EmailService::API
  class Api
    extend EmailService::EmailServiceInjector

    def self.addresses
      addresses_api # EmailServiceInjector provides readily configured emails api
    end

    def self.ses_client
      ses_client_instance
    end
  end
end
