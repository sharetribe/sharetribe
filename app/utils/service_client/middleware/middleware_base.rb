module ServiceClient
  module Middleware

    # Base class for middlewares.
    #
    # The subclasses may implement following methods:
    #
    # * `enter(ctx)`
    # * `leave(ctx)`
    # * `error(ctx)`
    #
    class MiddlewareBase

      def to_s
        self.class.name
      end

      def inspect
        self.class.name
      end

      def as_json(opts)
        to_s
      end
    end
  end
end
