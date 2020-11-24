module ServiceClient
  module Middleware

    # Adds a "X-Request-Id" header to the request. The ID can be used
    # for logging and debugging.
    #
    # Writes to req[:headers]["X-Request-Id"]
    #
    class RequestID < MiddlewareBase
      def enter(ctx)
        headers = ctx.fetch(:req).fetch(:headers)
        ctx[:req][:headers] = headers.merge("X-Request-Id" => SecureRandom.uuid)
        ctx
      end
    end
  end
end
