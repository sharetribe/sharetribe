module PaypalService
  class Merchant

    def initialize(endpoint, api_credentials, logger)
      @logger = logger

      PayPal::SDK.configure({
        mode: endpoint.endpoint_name.to_s,
        username: api_credentials.username,
        password: api_credentials.password,
        signature: api_credentials.signature,
        app_id: api_credentials.app_id
      })

      @api = PayPal::SDK::Merchant.new

      def do_request(request)
        raise(ArgumentException, "Unknown request method #{request.method}")
      end

    end
  end
end
