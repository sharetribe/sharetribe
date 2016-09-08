module ServiceClient
  class Client
    def initialize(endpoints, middleware = [], http_client = HTTPClient)
      @_endpoints = endpoints
      @_context_runner = ContextRunner.new(middleware + [http_client])
    end

    def get(endpoint, params = {}, opts = {})
      execute(:get, endpoint, params, opts)
    end

    def post(endpoint, params = {}, opts = {})
      execute(:post, endpoint, params, opts)
    end

    private

    def execute(method, endpoint, params, opts)
      endpoint_url = @_endpoints[endpoint]

      raise ArgumentError.new("Couldn't find endpoint '#{endpoint}'") if endpoint_url.nil?

      ctx = @_context_runner.execute(
        url: endpoint_url,
        method: method,
        params: params,
        opts: opts
      )

      res = ctx.fetch(:res)

      if res.fetch(:success)
        Result::Success.new(
          status: res[:status],
          body: res[:body]
        )
      else
        Result::Error.new(res[:body],
          status: res[:status],
          body: res[:body]
        )
      end

    end
  end
end
