module PaypalService
  class Permissions

    include PermissionsActions

    def initialize(config, logger, action_handlers = PERMISSIONS_ACTIONS, api_builder = nil)
      @logger = logger
      @api_builder = api_builder || self.method(:build_api)
      @action_handlers = action_handlers

      unless (config.nil?)
        PayPal::SDK.configure(
          {
            mode: config[:endpoint][:endpoint_name],
            username: config[:api_credentials][:username],
            password: config[:api_credentials][:password],
            signature: config[:api_credentials][:signature],
            app_id: config[:api_credentials][:app_id],
          }
          )
      end
    end

    def do_request(request)
      action_def = @action_handlers[request[:method]]
      return exec_action(action_def, @api_builder.call(request), request) if action_def

      raise(ArgumentError, "Unknown request method #{request[:method]}")
    end

    def build_api(request)
      if (request[:token] && request[:token_secret])
        PayPal::SDK::Permissions::API.new({
            token: request[:token],
            token_secret: request[:token_secret]
        })
      else
        PayPal::SDK::Permissions::API.new
      end
    end


    private

    def ident(val)
      val
    end

    def exec_action(action_def, api, request)
      input_transformer = action_def[:input_transformer]
      wrapper_method = action_def[:wrapper_method_name] ? api.method(action_def[:wrapper_method_name]) : method(:ident)
      action_method = action_def[:action_method_name] ? api.method(action_def[:action_method_name]) : method(:ident)
      output_transformer = action_def[:output_transformer]

      input = input_transformer.call(request)
      request_id = @logger.log_request_input(request, input)
      wrapped = wrapper_method.call(input)

      begin
        response = action_method.call(wrapped)
        @logger.log_response(response, request_id)
        if (response.success?)
          output_transformer.call(response, api)
        else
          create_failure_response(response)
        end
      rescue PayPal::SDK::Core::Exceptions::ConnectionError => e
        @logger.error("Paypal permission service failed to respond.")
        DataTypes.create_failure_response({error_msg: "Paypal permission service failed to respond."})
      end

    end


    def create_failure_response(res)
      if (res.error.length > 0)
        DataTypes.create_failure_response({
          error_code: res.error[0].error_id.to_s,
          error_msg: res.error[0].message.to_s
        })
      else
        DataTypes.create_failure_response({})
      end
    end

  end
end
