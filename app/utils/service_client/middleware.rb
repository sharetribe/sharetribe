module ServiceClient

  # Base class for middlewares.
  #
  # Default implementations for `enter`, `leave` and `error`
  # return the context object `ctx` without manipulating it.
  # The subclasses can override all or some of these methods.
  #
  class Middleware
    def enter(ctx)
      ctx
    end

    def leave(ctx)
      ctx
    end

    def error(ctx)
      ctx
    end
  end
end
