module ServiceClient
  module Middleware
    class ResultMapper < MiddlewareBase

      def leave(ctx)
        res = ctx.fetch(:res)

        res_object =
          if res[:success]
            Result::Success.new(
              status: res[:status],
              body: res[:body]
            )
          else
            Result::Error.new(res[:body].to_s,
                              status: res[:status],
                              body: res[:body]
                             )
          end

        ctx[:res] = res_object
        ctx
      end

      def error(ctx)
        ctx[:res] = Result::Error.new("An error occured during the middleware processing", ctx)
        ctx
      end

    end
  end
end
