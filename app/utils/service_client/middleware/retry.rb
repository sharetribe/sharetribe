module ServiceClient
  module Middleware

    class Retry < MiddlewareBase

      # max_attempts is 1 by default, which means
      # that the retry mechanism is disabled by default
      #
      def initialize(max_attempts: 1)
        @max_attempts = max_attempts
      end

      def enter(ctx)
        attempts = ctx[:req][:attempts] || 0
        ctx[:req][:attempts] = attempts + 1
        ctx
      end

      def leave(ctx)
        if leave_needs_retry?(ctx)
          retry_context(ctx)
        else
          ctx
        end
      end

      def error(ctx)
        if error_needs_retry?
          retry_context(ctx)
        else
          ctx
        end
      end

      private

      def leave_needs_retry?(ctx)
        !max_attempts?(ctx) && !ctx.fetch(:res).fetch(:success)
      end

      def error_needs_retry?(ctx)
        !max_attempts?(ctx)
      end

      def max_attempts?(ctx)
        opts_max_attempts = ctx[:opts][:max_attempts]
        max_attempts = opts_max_attempts || @max_attempts

        ctx[:req][:attempts] >= max_attempts
      end

      def retry_context(ctx)
        ctx[:enter_queue] = ctx[:complete_stack].reverse
        ctx[:complete_stack] = []
        ctx
      end
    end
  end
end
