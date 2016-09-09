module ServiceClient
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

  class BodyEncoder < ServiceClient::Middleware
    def initialize(encoding)
      @_encoder = choose_encoder(encoding)
    end

    def enter(ctx)
      req = ctx.fetch(:params).fetch(:req)

      body = req[:body]
      headers = req.fetch(:headers)

      ctx[:params][:req][:body] = @_encoder.encode(body)
      ctx[:params][:req][:headers] = headers.merge(
        "Accept" => @_encoder.mime_type,
        "Content-Type" => @_encoder.mime_type
      )

      ctx
    end

    def leave(ctx)
      res = ctx.fetch(:params).fetch(:res)
      body = res[:body]

      ctx[:params][:res][:body] = @_encoder.decode(body)
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
