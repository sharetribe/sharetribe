module ServiceClient
  module Middleware

    class ParamEncoder < MiddlewareBase
      def enter(ctx)
        params = ctx[:req][:params]
        ctx[:req][:params] = encode(params)
        ctx
      end

      private

      def encode(params)
        Hash[params.map { |k, v| encode_param(k, v) }]
      end

      def encode_param(k, v)
        case v
        when Date
          # Convert to format: 2016-09-20T06:36:58.085Z
          [k, v.strftime("%FT%T.%LZ")]
        else
          [k, v.to_s]
        end
      end
    end
  end
end
