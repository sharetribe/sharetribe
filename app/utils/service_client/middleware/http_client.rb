module ServiceClient
  module Middleware
    class HTTPClient < MiddlewareBase
      def initialize(host)
        @_conn = Faraday.new(host) do |c|
          c.adapter  Faraday.default_adapter  # make requests with Net::HTTP
        end
      end

      def enter(ctx)
        res = send_request(ctx.slice(:req, :opts))

        ctx[:res] = {
          success: res.success?,
          status: res.status,
          body: res.body,
          headers: res.headers
        }
        ctx
      end

      private

      def send_request(req:, opts:)
        host,
        method,
        headers,
        path,
        params,
        body = req.values_at(:host, :method, :headers, :path, :params, :body)

        case method
        when :get
          @_conn.get do |req|
            req.params = params
            req.headers = headers
            req.url(path)
          end
        when :post
          @_conn.post do |req|
            req.body = body
            req.headers = headers
            req.url(path)
          end
        else
          raise ArgumentError.new("Unknown HTTP method '#{method}'")
        end

      end
    end
  end
end
