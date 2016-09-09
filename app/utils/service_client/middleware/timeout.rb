module ServiceClient
  module Middleware
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
