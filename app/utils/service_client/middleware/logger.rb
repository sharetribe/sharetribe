module ServiceClient
  module Middleware

    # Logger middleware logs the request and response. In addition, if
    # Timing middleware is in use, the Logger will also log the
    # `started_at` timestamp and the `duration`.
    class Logger < MiddlewareBase
      def initialize
        @logger = SharetribeLogger.new(:service_client)
      end

      def enter(ctx)
        try_log { @logger.info("Enter stage logging", :enter, enter_log(ctx)) }
        ctx
      end

      def leave(ctx)
        try_log { @logger.info("Leave stage logging", :leave, leave_log(ctx)) }
        ctx
      end

      def error(ctx)
        try_log { @logger.error("Error stage logging", :error, error_log(ctx)) }
        ctx
      end

      private

      def enter_log(ctx)
        {
          req: ctx.fetch(:req).except(:body)
        }
      end

      def leave_log(ctx)
        {
          req: ctx.fetch(:req).except(:body),
          res: ctx.fetch(:res).except(:body),
        }.merge(timing(ctx))
      end

      def error_log(ctx)
        {
          req: ctx.fetch(:req).except(:body),
          res: Maybe(ctx)[:res].except(:body).or_nil,
          error_class: ctx[:error].class.to_s,
        }.merge(timing(ctx))
      end

      def try_log(&block)
        block.call()
      rescue StandardError => e
        @logger.error("Middleware logging failed with exception: #{e.class}", :error)
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
