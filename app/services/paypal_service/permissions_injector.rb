module PaypalService
  module PermissionsInjector
    def paypal_permissions
      @paypal_permissions ||= PaypalService::Permissions.new(
        build_endpoint(APP_CONFIG),
        build_api_credentials(APP_CONFIG)
      )
    end


    private

    def build_endpoint(config)
      PaypalService::DataTypes.create_endpoint(config.paypal_endpoint)
    end

    def build_api_credentials(config)
      PaypalService::DataTypes.create_api_credentials(
        config.paypal_username,
        config.paypal_password,
        config.paypal_signature,
        config.paypal_app_id
      )
    end
  end
end
