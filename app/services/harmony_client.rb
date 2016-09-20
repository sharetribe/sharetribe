HarmonyClient = ServiceClient::Client.new(
  APP_CONFIG.harmony_api_url,
  {
    initiate_booking: "/bookings/initiate",
    create_bookable: "/bookables/create",
    show_bookable: "/bookables/show",
    query_timeslots: "/timeslots/query"
  },
  [
    ServiceClient::Middleware::RequestID.new,
    ServiceClient::Middleware::Timeout.new,
    ServiceClient::Middleware::Logger.new,
    ServiceClient::Middleware::Timing.new,
    ServiceClient::Middleware::BodyEncoder.new(:transit_json),
    ServiceClient::Middleware::ParamEncoder.new
  ]
)
