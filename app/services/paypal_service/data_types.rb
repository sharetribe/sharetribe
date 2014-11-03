module PaypalService
  module DataTypes

    Endpoint = EntityUtils.define_builder([:endpoint_name, one_of: ["live", "sandbox"]])

    APICredentials = EntityUtils.define_builder(
      [:username, :mandatory, :string],
      [:password, :mandatory, :string],
      [:signature, :mandatory, :string],
      [:app_id, :mandatory, :string])

    IpnHook = EntityUtils.define_builder([:url, :mandatory, :string])

    FailureResponse = EntityUtils.define_builder(
      [:success, const_value: false],
      [:error_code, :string],
      [:error_msg, :string])

    Config = EntityUtils.define_builder(
      [:endpoint, :mandatory],
      [:api_credentials, :mandatory],
      [:ipn_hook],
      [:button_source, :string])


    module_function

    def create_endpoint(opts); Endpoint.call(opts) end
    def create_api_credentials(opts); APICredentials.call(opts) end
    def create_ipn_hook(opts); IpnHook.call(opts) end
    def create_config(opts); Config.call(opts) end

    def create_failure_response(opts); FailureResponse.call(opts) end

  end
end
