module ServiceClient
  class EndpointMapper < Middleware
    def initialize(endpoint_map)
      @_endpoint_map = endpoint_map
    end

    def enter(ctx)
      endpoint = ctx[:params][:endpoint]

      if endpoint.nil?
        raise ArgumentError.new(
                "EndpointMapper middleware expects :endpoint to be defined in the context")
      end

      path = @_endpoint_map[endpoint]

      if path.nil?
        raise ArgumentError.new(
                "Unknown endpoint: '#{endpoint}'")
      end

      ctx[:params][:req][:path] = path
      ctx
    end
  end
end
