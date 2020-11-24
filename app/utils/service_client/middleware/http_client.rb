module ServiceClient
  module Middleware

    # HTTP Client middleware.
    #
    # 1. Reads ctx[:req]
    # 2. Makes an HTTP request.
    # 3. Writes the result to ctx[:res]
    #
    class HTTPClient < MiddlewareBase
      def initialize(host)
        @_conn = Faraday.new(host) do |c|
          c.response :encoding
          c.adapter Faraday.default_adapter # make requests with Net::HTTP
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
        method,
        params,
        body = req.values_at(:method, :params, :body)

        case method
        when :get
          @_conn.get do |faraday_req|
            faraday_req.params = params

            setup_request(faraday_req, req)
          end
        when :post
          @_conn.post do |faraday_req|
            faraday_req.params = params
            faraday_req.body = body

            setup_request(faraday_req, req)
          end
        else
          raise ArgumentError.new("Unknown HTTP method '#{method}'")
        end

      end

      def setup_request(faraday_req, req)
        headers,
        path,
        timeout,
        open_timeout = req.values_at(:headers, :path, :timeout, :open_timeout)

        faraday_req.headers = headers
        faraday_req.url(path)
        faraday_req.options.timeout = timeout if timeout
        faraday_req.options.open_timeout = open_timeout if open_timeout
      end
    end
  end
end
