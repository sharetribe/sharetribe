# ContextRunner is an implementation of the context execution
# process. It takes a set of middlewares and knows how to execute an
# operation in the context of them.
#
# Operation execution is triggered by calling the execute method
# with per execution parameters. The executor composes the
# middleware and the parameters into an execution context map. It
# then begins the execution by calling the enter phase for all
# middlewares that define it in the given order. When the enter
# phases for all middlewares are processed the execution moves to
# leave state. Leave states of all middlewares that support it are
# called in reverse order.
#
# During the execution phases the state of execution is maintained
# in the context map and threaded through all the functions
# invoked on middleware. Every phase of every middleware can
# modify the context during the execution. This model is very
# similar to (and inpired by) how the Clojure web framework
# pedestal implements and executes interceptors:
# https://github.com/pedestal/pedestal/blob/master/guides/documentation/service-interceptors.md
class ContextRunner

  attr_reader :middleware

  def initialize(middleware)
    @middleware = middleware || []
  end

  # A hook for overriding. The default implementation just puts all
  # middleware into the enter queue in order. If you want a dynamic
  # behavior where params affect the included middleware or its
  # ordering this is the place to do it.
  #
  # The queue is modelled as an array where next item is taken
  # from the end of the array by calling .pop() on it.
  def build_enter_queue(params, middleware)
    middleware.reverse
  end

  # Build a context map for execution. The context map is just a
  # hash but the context execution mechanism defines a small set
  # of reserved keys that it uses to control the execution
  # process. All other keys are free to be used by the middleware
  # implementations to pass on information in the chain.
  #
  # ==== Context Hash
  # * <tt>params</tt> - The parameters passed to execute. Executor
  # has no use for these parameters so interpreting them is
  # entirely up to middleware.
  # * <tt>enter_queue</tt> - A queue (impl Array) of middlewares
  # that still need to be executed during the 'enter' phase.
  # * <tt>leave_stack</tt> - A stack (impl Array) of middlewares
  # that still need to be executed during the 'leave' phase.
  # * <tt>error</tt> - The most recently uncaught error. If a
  # middleware raises an error the next middleware in the stack
  # will have its error method called with ctx and the error. If
  # the error method either raises a new error, reraises the same
  # error or returns the ctx with error key in place the error
  # handling will proceed to call the next middleware in the
  # stack. A middleware error handler can resolve an error by
  # returning a context with the error key removed (or set to
  # nil). In this case the context running will proceed to call
  # leave functions of all remaining middleware in the stack.
  def build_ctx(params)
    (params || {}).merge(
      enter_queue: build_enter_queue(params, middleware),
      leave_stack: [])
  end

  def execute(params)
    ctx = build_ctx(params)
    execute_ctx(ctx)
  end


  private

  def try_execute_mw(ctx, mw, stage, &block)
    block.call
  rescue StandardError => e
    new_ctx = ctx.dup
    new_ctx[:error] = e
    new_ctx[:error_middleware] = mw.class.name
    new_ctx[:error_stage] = stage
    new_ctx
  end

  def next_mw(ctx)
    new_ctx = ctx.dup

    if ctx[:error]
      mw = new_ctx[:leave_stack].shift

      [new_ctx, mw, :error]
    elsif !new_ctx[:enter_queue].empty?
      mw = new_ctx[:enter_queue].pop
      new_ctx[:leave_stack].unshift(mw)

      [new_ctx, mw, :enter]
    else
      mw = new_ctx[:leave_stack].shift

      [new_ctx, mw, :leave]
    end
  end

  def execute_ctx(ctx)
    ctx, mw, type = next_mw(ctx)

    while mw
      ctx = try_execute_mw(ctx, mw, type) do
        if mw.respond_to?(type)
          mw.send(type, ctx)
        else
          ctx
        end
      end

      ctx, mw, type = next_mw(ctx)
    end

    ctx
  end

end
