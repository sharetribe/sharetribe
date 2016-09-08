module ServiceClient
  class Logger < ServiceClient::Middleware
    def initialize
      @logger = SharetribeLogger.new(:service_client)
    end

    def enter(ctx)
      @logger.info("Enter", :enter, ctx)
      ctx
    end

    def leave(ctx)
      @logger.info("Leave", :leave, ctx)
      ctx
    end

    def error(ctx)
      @logger.info("Error", :error, ctx)
      ctx
    end
  end
end
