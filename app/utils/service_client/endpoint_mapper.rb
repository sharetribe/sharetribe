module ServiceClient
  class EndpointMapper < Middleware
    def enter(ctx)
      endpoint_map = ctx[:params][:endpoint_map]
      endpoint = ctx[:params][:endpoint]

      if endpoint.nil?
        raise ArgumentError.new(
                "EndpointMapper middleware expects :endpoint to be defined in the context")
      end

      path = endpoint_map[endpoint]

      if path.nil?
        raise ArgumentError.new(
                "Unknown endpoint: '#{endpoint}'")
      end

      ctx[:params][:req][:path] = path
      ctx
    end
  end
end
