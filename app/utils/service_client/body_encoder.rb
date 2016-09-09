module ServiceClient
  class JSONEncoder
    def encode(body)
      body.to_json
    end

    def decode(body)
      JSON.parse(body)
    end
  end

  class BodyEncoder < ServiceClient::Middleware
    def initialize(encoding)
      @_encoding = encoding
    end

    def enter(ctx)
      req = ctx.fetch(:params).fetch(:req)
      body = req[:body]

      ctx[:params][:req][:body] = choose_encoder(@_encoding).encode(body)
      ctx
    end

    def leave(ctx)
      res = ctx.fetch(:params).fetch(:res)
      body = res[:body]

      # TODO We should probably use the 'res' object information
      # to decide which decoder to use
      ctx[:params][:res][:body] = choose_encoder(@_encoding).decode(body)
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
