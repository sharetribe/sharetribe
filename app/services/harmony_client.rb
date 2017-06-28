HarmonyClient = ServiceClient::Client.new(
  APP_CONFIG.harmony_api_url,
  HarmonyEndpoints::ENDPOINT_MAP,
  [
    ServiceClient::Middleware::Retry.new,
    ServiceClient::Middleware::RequestID.new,
    ServiceClient::Middleware::Timeout.new,
    ServiceClient::Middleware::Logger.new,
    ServiceClient::Middleware::Timing.new,
    ServiceClient::Middleware::BodyEncoder.new(:transit_msgpack),
    ServiceClient::Middleware::ParamEncoder.new,
    ServiceClient::Middleware::JwtAuthenticator.new(
      secret: APP_CONFIG.harmony_api_token_secret,
      default_auth_context: ->(){
        session_ctx = SessionContextStore.get

        {
          marketplace_id: session_ctx[:marketplace_uuid],
          actor_id: session_ctx[:user_uuid] || UUIDUtils.v0_uuid,
          actor_role: session_ctx[:user_role]
        }
      }),
  ]
)
