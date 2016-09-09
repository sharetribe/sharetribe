module ServiceClient
  class RequestID < ServiceClient::Middleware
    def enter(ctx)
      headers = ctx.fetch(:req).fetch(:headers)
      ctx[:req][:headers] = headers.merge("X-Request-Id" => SecureRandom.uuid)
      ctx
    end
  end
end
