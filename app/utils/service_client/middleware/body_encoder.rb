module ServiceClient
  module Middleware

    class JSONEncoder
      def encode(body)
        body.to_json
      end

      def decode(body)
        JSON.parse(body)
      end
    end

    class TransitEncoder

      def initialize(encoding)
        @_encoding = encoding
      end

      def decode(body)
        TransitUtils.decode(body, @_encoding)
      end

      def encode(body)
        TransitUtils.encode(body, @_encoding)
      end
    end

    class TextEncoder
      def encode(body)
        body.to_s
      end

      def decode(body)
        body
      end
    end

    # Encodes the body to given encoding.
    #
    # The encoding is given to the constructor and that encoding is
    # used encode the request. For response, the Content-Type header
    # is used to define which decoder to use.
    #
    # Reads from res[:body] and writes to res[:body]
    #
    class BodyEncoder < MiddlewareBase

      ENCODERS = [
        {encoding: :json, media_type: "application/json", encoder: JSONEncoder.new},
        {encoding: :transit_json, media_type: "application/transit+json", encoder: TransitEncoder.new(:json)},
        {encoding: :transit_msgpack, media_type: "application/transit+msgpack", encoder: TransitEncoder.new(:msgpack)},
        {encoding: :text, media_type: "text/plain", encoder: TextEncoder.new},
      ]

      class ParsingError < StandardError
      end

      def initialize(encoding, decode_response: true, encode_request: true)
        encoder = encoder_by_encoding(encoding)

        if encoder.nil?
          raise ArgumentError.new("Coulnd't find encoder for encoding: '#{encoding}'")
        end

        @_default_encoder = encoder
        @_decode_response = decode_response
        @_encode_request = encode_request
      end

      def enter(ctx)
        req = ctx.fetch(:req)
        opts_encoding = ctx.dig(:opts, :encoding)
        encode_request = Maybe(ctx.dig(:opts, :encode_request)).or_else(@_encode_request)
        encoder = encoder_by_encoding(opts_encoding) || @_default_encoder

        body = req[:body]
        headers = req.fetch(:headers)
        accept = encoder[:media_type]
        content_type = body.nil? ? nil : encoder[:media_type]

        ctx[:req][:headers]["Accept"] = accept

        # Encode only if the Content-Type differs from the target Content-Type.
        # This makes the middleware idempotent.
        if ctx[:req][:headers]["Content-Type"] != content_type
          if encode_request
            ctx[:req][:body] = encoder[:encoder].encode(body)
          end

          ctx[:req][:headers]["Content-Type"] = content_type
        end

        ctx
      end

      def leave(ctx)
        decode_response = Maybe(ctx.dig(:opts, :decode_response)).or_else(@_decode_response)

        return ctx unless decode_response

        res = ctx.fetch(:res)
        headers = res.fetch(:headers)
        body = res[:body]

        # Choose encoder by the Content-Type header, if possible.
        # Otherwise, fallback to the same encoder we used to encode the request
        encoder = encoder_by_content_type(headers["Content-Type"]) || @_default_encoder

        begin
          ctx[:res][:body] = encoder[:encoder].decode(body)
        rescue StandardError => e
          raise ParsingError.new("Parsing error, msg: '#{e.message}', body: '#{body}'")
        end
        ctx
      end

      private

      def encoder_by_encoding(encoding)
        ENCODERS.find { |e| e[:encoding] == encoding }
      end

      def encoder_by_content_type(content_type)
        media_type = HTTPUtils.parse_content_type(content_type)

        ENCODERS.find { |e| e[:media_type] == media_type }
      end
    end
  end
end
