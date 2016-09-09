module ServiceClient
  class ResultMapper < Middleware

    def leave(ctx)
      res = ctx.fetch(:params).fetch(:res)

      res_object =
        if res.fetch(:success)
          Result::Success.new(
            status: res[:status],
            body: res[:body]
          )
        else
          Result::Error.new(res[:body],
                            status: res[:status],
                            body: res[:body]
                           )
        end

      ctx[:params][:res] = res_object
      ctx
    end

    def error(ctx)
      ctx[:params][:res] = Result::Error.new("An error occured during the middleware processing", ctx)
      ctx
    end

  end
end
