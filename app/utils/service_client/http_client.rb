module ServiceClient
  class HTTPClient < Middleware
    def enter(ctx)
      res = send_request(ctx.fetch(:params).slice(:req, :opts))

      ctx.merge(
        res: {
          success: res.success?,
          status: res.status,
          body: res.body,
          headers: res.headers
        }
      )
    end

    private

    def send_request(req:, opts:)
      host,
      method,
      path = req.values_at(:host, :method, :path)

      conn = Faraday.new(host) do |c|
        c.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      end

      case method
      when :get
        conn.get do |req|
          req.url(path)
        end
      else
        raise argumenterror.new("unknown http method '#{method}'")
      end

    end
  end
end
