module ServiceClient
  module Middleware

    # Adds timeout options to the context.
    #
    # This middleware only adds the options to context, but relies on HTTPClient
    # to actually implement the timeout feature.
    #
    # Writes:
    #
    # {
    #   req: {
    #     timeout: <timeout>,
    #     open_timout: <open_timeout>
    #   }
    # }
    #
    class Timeout < MiddlewareBase

      TIMEOUT      = 5
      OPEN_TIMEOUT = 2

      def initialize(timeout: TIMEOUT, open_timeout: OPEN_TIMEOUT)
        @_timeout = timeout
        @_open_timeout = open_timeout
      end

      def enter(ctx)
        req = ctx.fetch(:req)
        ctx[:req] = req.merge(timeout: @_timeout, open_timeout: @_open_timeout)
        ctx
      end
    end
  end
end
