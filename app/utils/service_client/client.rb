##
# ServiceClient is a generalized way to call external services from
# the Rails application
#
# It uses an Interceptor pattern, which makes it very easy to tailor a
# client that is suitable for different needs. It's easy to pick only
# the middleware that is needed and it's also easy to extend the
# client by writing a new middleware.
#
module ServiceClient
  class Client

    ##
    # Create a new ServiceClient instance
    #
    # ## Params:
    #
    # - `host`: The host (e.g. "http://myservice.example.com")
    # - `endpoint_map`: Maps endpoint names to endpoint URLs
    # - `middleware`: Array of middleware
    # - `opts`: Extra options
    #
    # ## Usage:
    #
    # ```
    # car_service = ServiceClient::Client.new("http://carservice.example.com",
    #                                         {
    #                                           list: "/list_cars",
    #                                           sell: "/sell_car"
    #                                         },
    #                                         [
    #                                           ServiceClient::Middleware::RequestID.new,
    #                                           ServiceClient::Middleware::Timeout.new,
    #                                           ServiceClient::Middleware::Logger.new,
    #                                           ServiceClient::Middleware::Timing.new,
    #                                           ServiceClient::Middleware::BodyEncoder.new(:transit_msgpack)
    #                                         ]
    # ```
    #
    # The example above will create a new client that post request to
    # car service URL. It has two known endpoints :buy and :sell, and it uses 5 middleware.
    #
    # ## Default middleware:
    #
    # In addition to the user-specified middleware, the Client will
    # have 3 predefined middleware. Those are:
    #
    # * ResultMapper: Maps the HTTP result to Result object
    # * EndpointMapper: Maps the endpoint name to endpoint URL
    # * HTTPClient: Does the actual HTTP request
    #
    def initialize(host, endpoint_map, middleware = [], opts = {})
      @_raise_errors = opts[:raise_errors]

      before_middleware = [
        Middleware::ResultMapper.new
      ]

      after_middleware = [
        Middleware::EndpointMapper.new(endpoint_map),
        (opts[:http_client] || Middleware::HTTPClient).new(host)
      ]

      @_context_runner = ContextRunner.new(
        before_middleware +
        middleware +
        after_middleware
      )
    end

    # Sends a GET request to the service.
    #
    # Usage:
    #
    # car_service.get(:list, params: {make: :toyota, year: 2010})
    #
    # Params:
    #
    # - `endpoint`: The endpoint name
    # - `params`: Query params
    # - `opts`: Optional options that may control middleware
    #
    # Returns:
    #
    # Result::Success or Result::Error
    #
    def get(endpoint, params: {}, opts: {})
      ctx = execute(
        method: :get,
        endpoint: endpoint,
        params: params,
        body: nil,
        opts: opts)

      ctx.fetch(:res)
    end

    # Sends a POST request to the service.
    #
    # Usage:
    #
    # car_service.post(:list,
    #                  body: {
    #                    make: :toyota, year: 2010,
    #                    description: "This is my old Toyota in good condition!"
    #                  })
    #
    # Params:
    #
    # - `endpoint`: The endpoint name
    # - `body`: Body params
    # - `params`: Query params
    # - `opts`: Optional options that may control middleware
    #
    # Returns:
    #
    # Result::Success or Result::Error
    #
    def post(endpoint, body: nil, params: {}, opts: {})
      ctx = execute(
        method: :post,
        endpoint: endpoint,
        body: body,
        params: params,
        opts: opts)

      ctx.fetch(:res)
    end

    private

    def execute(method:, endpoint:, params:, body:, opts:)
      ctx = @_context_runner.execute(
        req: {
          path: nil,
          method: method,
          params: params,
          body: body,
          headers: {}
        },
        endpoint: endpoint,
        opts: opts
      )

      if ctx[:error] && @_raise_errors
        raise ctx[:error]
      end

      ctx
    end
  end
end
