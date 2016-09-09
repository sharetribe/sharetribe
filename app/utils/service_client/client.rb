module ServiceClient
  class Client
    def initialize(host, middleware = [], opts)
      @_host = host
      @_raise_errors = opts[:raise_errors]
      http_client = opts[:http_client] || HTTPClient

      @_context_runner = ContextRunner.new(middleware + [http_client.new])
    end

    def get(endpoint, params: {}, opts: {})
      ctx = execute(
        method: :get,
        endpoint: endpoint,
        params: params,
        body: nil,
        opts: opts)

      ctx.fetch(:res)
    end

    def post(endpoint, body: nil, opts: {})
      ctx = execute(
        method: :post,
        endpoint: endpoint,
        body: body,
        params: {},
        opts: opts)

      ctx.fetch(:res)
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
        opts: opts
      )

      if ctx[:error] && @_raise_errors
        raise ctx[:error]
      end

      ctx
    end
  end
end
