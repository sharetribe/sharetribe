HarmonyClient = ServiceClient::Client.new(
  APP_CONFIG.harmony_api_url,
  {
    # Bookables
    create_bookable: "/bookables/create",
    show_bookable: "/bookables/show",

    # Timeslots
    query_timeslots: "/timeslots/query",

    # Bookings
    initiate_booking: "/bookings/initiate",
    accept_booking: "/bookings/accept",
    reject_booking: "/bookings/reject"
  },
  [
    ServiceClient::Middleware::Retry.new,
    ServiceClient::Middleware::RequestID.new,
    ServiceClient::Middleware::Timeout.new,
    ServiceClient::Middleware::Logger.new,
    ServiceClient::Middleware::Timing.new,
    ServiceClient::Middleware::BodyEncoder.new(:transit_json),
    ServiceClient::Middleware::ParamEncoder.new,
    ServiceClient::Middleware::JwtAuthenticator.new(APP_CONFIG.harmony_api_disable_authentication,
                                                    APP_CONFIG.harmony_api_token_secret),
  ]
)
