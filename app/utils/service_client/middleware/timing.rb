module ServiceClient
  module Middleware

    # Adds `started_at` timestamp on `enter` phase and calculates
    # `duration` on `leave` and `error` phases.
    #
    # Writes to context:
    #
    # {
    #   started_at: <Time>,
    #   duration: <duration in milliseconds
    # }
    class Timing < MiddlewareBase

      def initialize(now = nil)
        @now = now || ->() { Time.now }
      end

      def enter(ctx)
        ctx.merge(started_at: @now.call)
      end

      def leave(ctx)
        add_duration(ctx)
      end

      def error(ctx)
        add_duration(ctx)
      end

      private

      def add_duration(ctx)
        ctx.merge(
          duration: duration_ms(ctx[:started_at]))
      end

      def duration_ms(started_at)
        (@now.call - started_at) * 1000
      end
    end
  end
end
