module ServiceClient
  class Client
    def initialize(host, endpoint_map, middleware = [], opts = {})
      @_host = host
      @_raise_errors = opts[:raise_errors]
      @_endpoint_map = endpoint_map

      @_context_runner = ContextRunner.new(
        [ResultMapper.new] +
        middleware +
        [
          EndpointMapper.new,
          (opts[:http_client] || HTTPClient).new
        ])
    end

    def get(endpoint, params: {}, opts: {})
      ctx = execute(
        method: :get,
        endpoint: endpoint,
        params: params,
        body: nil,
        opts: opts)

      ctx.fetch(:params).fetch(:res)
    end

    def post(endpoint, body: nil, opts: {})
      ctx = execute(
        method: :post,
        endpoint: endpoint,
        body: body,
        params: {},
        opts: opts)

      ctx.fetch(:params).fetch(:res)
    end

    private

    def execute(method:, endpoint:, params:, body:, opts:)
      ctx = @_context_runner.execute(
        req: {
          host: @_host,
          path: nil,
          method: method,
          params: params,
          body: body,
          headers: {}
        },
        endpoint: endpoint,
        endpoint_map: @_endpoint_map,
        opts: opts
      )

      if ctx[:error] && @_raise_errors
        raise ctx[:error]
      end

      ctx
    end
  end
end
