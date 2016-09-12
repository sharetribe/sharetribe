module ServiceClient
  module Middleware
    class Logger < MiddlewareBase
      def initialize
        @logger = SharetribeLogger.new(:service_client)
      end

      def enter(ctx)
        @logger.info("Enter", :enter, enter_log(ctx))
        ctx
      end

      def leave(ctx)
        @logger.info("Leave", :leave, leave_log(ctx))
        ctx
      end

      def error(ctx)
        @logger.info("Error", :error, error_log(ctx))
        ctx
      end

      private

      def enter_log(ctx)
        {
          req: ctx.fetch(:req)
        }
      end

      def leave_log(ctx)
        {
          req: ctx.fetch(:req),
          res: ctx.fetch(:res),
        }.merge(timing(ctx))
      end

      def error_log(ctx)
        {
          req: ctx[:req],
          res: ctx[:res],
          error: ctx[:error],
        }.merge(timing(ctx))
      end

      # Picks started_at and duration values from the context
      # Those values are added by the Timing middleware
      def timing(ctx)
        {
          started_at: ctx[:started_at],
          duration: ctx[:duration]
        }.compact
      end
    end
  end
end
