module ServiceClient
  module Middleware

    # Takes an endpoint map as a constructor argument. Maps the endpoint name on `enter` phase to real endpoint URL.
    #
    # Reads ctx[:endpoint]
    # Writes to ctx[:req][:path]
    #
    class EndpointMapper < MiddlewareBase
      def initialize(endpoint_map)
        @_endpoint_map = endpoint_map
      end

      def enter(ctx)
        req = ctx.fetch(:req)
        endpoint = ctx.fetch(:endpoint)

        if endpoint.nil?
          raise ArgumentError.new(
                  "EndpointMapper middleware expects :endpoint to be defined in the context")
        end

        path = @_endpoint_map[endpoint]

        if path.nil?
          raise ArgumentError.new(
                  "Unknown endpoint: '#{endpoint}'")
        end

        ctx[:req][:path] = path
        ctx
      end
    end
  end
end
