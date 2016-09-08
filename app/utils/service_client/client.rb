module ServiceClient
  class Client
    def initialize(url, middleware = [], opts)
      @_raise_errors = opts[:raise_errors]
      http_client = opts[:http_client] || HTTPClient
      @_context_runner = ContextRunner.new(middleware + [http_client.new(url)])
    end

    def get(endpoint, params = {}, opts = {})
      execute(:get, endpoint, params, opts).fetch(:res)
    end

    def post(endpoint, params = {}, opts = {})
      execute(:post, endpoint, params, opts).fetch(:res)
    end

    private

    def execute(method, endpoint, params, opts)
      ctx = @_context_runner.execute(
        endpoint: endpoint,
        method: method,
        params: params,
        opts: opts
      )

      if ctx[:error] && @_raise_errors
        raise ctx[:error]
      end

      ctx
    end
  end
end
