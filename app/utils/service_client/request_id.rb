module ServiceClient
  class RequestID < ServiceClient::Middleware
    def enter(ctx)
      ctx[:params] = ctx[:params].merge(request_id: SecureRandom.uuid)
      ctx
    end
  end
end
