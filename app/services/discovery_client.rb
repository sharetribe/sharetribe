DiscoveryClient = ServiceClient::Client.new(
  APP_CONFIG.discovery_api_url,
  {
    # Listings
    query_listings: "/discovery/listings/query",

  },
  [
    ServiceClient::Middleware::Retry.new,
    ServiceClient::Middleware::RequestID.new,
    ServiceClient::Middleware::Timeout.new,
    ServiceClient::Middleware::Logger.new,
    ServiceClient::Middleware::Timing.new,
    ServiceClient::Middleware::BodyEncoder.new(:transit_json, decode_response: false),
    ServiceClient::Middleware::ParamEncoder.new,
    ServiceClient::Middleware::APIKeyAuthenticator.new(APP_CONFIG.discovery_api_key),
  ]
)
