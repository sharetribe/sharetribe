module ServiceClient
  module Middleware

    class APIKeyAuthenticator < MiddlewareBase

      def initialize(api_key)
        @_api_key = api_key
      end

      def enter(ctx)
        ctx[:req][:headers]["Authorization"] = "apikey key=#{@_api_key}"
        ctx
      end
    end
  end
end
