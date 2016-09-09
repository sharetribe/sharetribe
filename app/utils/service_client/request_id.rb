module ServiceClient
  class RequestID < ServiceClient::Middleware
    def enter(ctx)
      headers = ctx.fetch(:params).fetch(:req).fetch(:headers)
      ctx[:params][:req][:headers] = headers.merge("X-Request-Id" => SecureRandom.uuid)

      ctx
    end
  end
end
