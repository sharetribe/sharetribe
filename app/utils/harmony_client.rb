HarmonyClient =
  ServiceClient::Client.new("http://localhost:8085",
                            {
                              query_time_slots: "/timeslots/query",
                              create_bookable: "/bookables/create",
                            },
                            [
                              ServiceClient::Middleware::RequestID.new,
                              ServiceClient::Middleware::Logger.new,
                              ServiceClient::Middleware::BodyEncoder.new(:json),
                            ],
                            raise_errors: true
                           )
