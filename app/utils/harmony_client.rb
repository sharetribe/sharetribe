HarmonyClient =
  ServiceClient::Client.new("http://localhost:8080",
                            {
                              authors: "/v1/authors"
                            },
                            [
                              ServiceClient::Middleware::RequestID.new,
                              ServiceClient::Middleware::Logger.new,
                              ServiceClient::Middleware::BodyEncoder.new(:json),
                            ],
                            raise_errors: true
                           )
