require_relative '../../app/utils/service_client/middleware/request_id'
require_relative '../../app/utils/service_client/middleware/retry'
require_relative '../../app/utils/service_client/middleware/timeout'
require_relative '../../app/utils/service_client/middleware/logger'
require_relative '../../app/utils/service_client/middleware/timing'
require_relative '../../app/utils/service_client/middleware/body_encoder'
require_relative '../../app/utils/service_client/middleware/param_encoder'
require_relative '../../app/utils/service_client/middleware/api_key_authenticator'

DiscoveryClient = ServiceClient::Client.new(
  APP_CONFIG.discovery_api_url,
  {
    # Listings
    query_listings: "/discovery/listings/query"

  },
  [
    ServiceClient::Middleware::Retry.new,
    ServiceClient::Middleware::RequestId.new,
    ServiceClient::Middleware::Timeout.new,
    ServiceClient::Middleware::Logger.new,
    ServiceClient::Middleware::Timing.new,
    ServiceClient::Middleware::BodyEncoder.new(:transit_json, decode_response: false),
    ServiceClient::Middleware::ParamEncoder.new,
    ServiceClient::Middleware::APIKeyAuthenticator.new(APP_CONFIG.discovery_api_key),
  ]
)
