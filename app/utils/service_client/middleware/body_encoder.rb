module ServiceClient
  module Middleware
    class JSONEncoder
      def encode(body)
        body.to_json unless body.nil?
      end

      def decode(body)
        JSON.parse(body) unless body.nil?
      end

      def mime_type
        "application/json"
      end
    end

    class TransitEncoder

      ENCODINGS = {
        json: "application/transit+json",
        msgpack: "application/transit+msgpack",
      }

      def initialize(encoding)
        @_encoding = encoding
      end

      def decode(body)
        TransitUtils.decode(body, @_encoding) unless body.nil?
      end

      def encode(body)
        TransitUtils.encode(body, @_encoding) unless body.nil?
      end

      def mime_type
        ENCODINGS[@_encoding]
      end
    end

    class BodyEncoder < MiddlewareBase
      class ParsingError < StandardError
      end

      def initialize(encoding)
        @_encoder = choose_encoder(encoding)
      end

      def enter(ctx)
        req = ctx.fetch(:req)

        body = req[:body]
        headers = req.fetch(:headers)

        ctx[:req][:body] = @_encoder.encode(body)
        ctx[:req][:headers]["Accept"] = @_encoder.mime_type
        ctx[:req][:headers]["Content-Type"] = @_encoder.mime_type unless body.nil?

        ctx
      end

      def leave(ctx)
        res = ctx.fetch(:res)
        body = res[:body]

        begin
          ctx[:res][:body] = @_encoder.decode(body)
        rescue StandardError => e
          raise ParsingError.new("Parsing error, msg: '#{e.message}', body: '#{body}'")
        end
        ctx
      end

      private

      def choose_encoder(enc)
        case enc
        when :json
          JSONEncoder.new
        when :transit_json
          TransitEncoder.new(:json)
        when :transit_msgpack
          TransitEncoder.new(:msgpack)
        else
          ArgumentError.new("Unknown encoder: '#{enc}'")
        end
      end
    end
  end
end
