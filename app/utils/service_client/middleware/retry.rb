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
        ctx[:retry_queue] = build_retry_queue(ctx)
        ctx
      end

      def leave(ctx)
        if leave_needs_retry?(ctx)
          retry_leave_context(ctx)
        else
          ctx
        end
      end

      def error(ctx)
        if error_needs_retry?(ctx)
          retry_error_context(ctx)
        else
          ctx
        end
      end

      private

      def build_retry_queue(ctx)
        # Add also `self` to the queue, because we want the Retry
        # middleware to be in the retry queue.
        ctx.fetch(:enter_queue).dup + [self]
      end

      # Retries if all attempts are not used and
      # status is 5xx
      def leave_needs_retry?(ctx)
        !max_attempts?(ctx) && (500..599).cover?(ctx.fetch(:res).fetch(:status))
      end

      def error_needs_retry?(ctx)
        !max_attempts?(ctx)
      end

      def max_attempts?(ctx)
        opts_max_attempts = ctx[:opts][:max_attempts]
        max_attempts = opts_max_attempts || @max_attempts

        ctx[:req][:attempts] >= max_attempts
      end

      def retry_leave_context(ctx)
        ctx[:enter_queue] = ctx[:retry_queue]
        ctx
      end

      def retry_error_context(ctx)
        ctx[:enter_queue] = ctx[:retry_queue]
        ctx[:error] = nil
        ctx
      end
    end
  end
end
