module PaypalService
  class Merchant

    include MerchantActions

    attr_reader :action_handlers

    def initialize(config, logger, action_handlers = MERCHANT_ACTIONS, api_builder = nil)
      @logger = logger
      @api_builder = api_builder || self.method(:build_api)
      @action_handlers = action_handlers
      @config = config

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
      return exec_action(action_def, @api_builder.call(request), @config, request) if action_def

      raise ArgumentError.new("Unknown request method #{request[:method]}")
    end


    def build_api(request)
      req = request.to_h
      if (req[:receiver_username])
        PayPal::SDK::Merchant.new(nil, { subject: req[:receiver_username] })
      else
        PayPal::SDK::Merchant.new
      end
    end


    private

    def exec_action(action_def, api, config, request)
      input_transformer = action_def[:input_transformer]
      wrapper_method = api.method(action_def[:wrapper_method_name])
      action_method = api.method(action_def[:action_method_name])
      output_transformer = action_def[:output_transformer]

      input = input_transformer.call(request, config)
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
        @logger.error("Paypal merchant service failed to respond.")

        error_code =
          if (e.is_a? PayPal::SDK::Core::Exceptions::TimeoutError)
            "x-timeout"
          elsif (e.is_a? PayPal::SDK::Core::Exceptions::ServerError)
            "x-servererror"
          else
            "x-unknown-paypalerror"
          end

        DataTypes.create_failure_response({
          error_code: error_code,
          error_msg: "Paypal merchant service failed to respond."
        })
      end

    end


    def create_failure_response(res)
      if (res.errors.length > 0)
        DataTypes.create_failure_response({
          error_code: res.errors[0].error_code.to_s,
          error_msg: res.errors[0].long_message.to_s
        })
      else
        DataTypes.create_failure_response({})
      end
    end
  end
end
