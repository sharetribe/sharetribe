module ServiceClient
  module Middleware
    class JSONEncoder
      def encode(body)
        body.to_json
      end

      def decode(body)
        JSON.parse(body)
      end

      def mime_type
        "application/json"
      end
    end

    class BodyEncoder < MiddlewareBase
      def initialize(encoding)
        @_encoder = choose_encoder(encoding)
      end

      def enter(ctx)
        req = ctx.fetch(:req)

        body = req[:body]
        headers = req.fetch(:headers)

        ctx[:req][:body] = @_encoder.encode(body)
        ctx[:req][:headers] = headers.merge(
          "Accept" => @_encoder.mime_type,
          "Content-Type" => @_encoder.mime_type
        )

        ctx
      end

      def leave(ctx)
        res = ctx.fetch(:res)
        body = res[:body]

        ctx[:res][:body] = @_encoder.decode(body)
        ctx
      end

      private

      def choose_encoder(enc)
        case enc
        when :json
          JSONEncoder.new
        else
          ArgumentError.new("Unknown encoder: '#{enc}'")
        end
      end
    end
  end
end
