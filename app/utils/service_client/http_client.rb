module ServiceClient
  class HTTPClient < Middleware
    def initialize(url)
      @url = url
    end

    def enter(ctx)
      path, method, params = ctx[:params].values_at(:url, :method, :params)

      res = send_request(path, method, params)

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

    def send_request(path, method, params)
      conn = Faraday.new(@url) do |c|
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
