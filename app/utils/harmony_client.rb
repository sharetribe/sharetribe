HarmonyClient =
  ServiceClient::Client.new("http://localhost:8080",
                            {
                              authors: "/v1/authors"
                            },
                            [
                              ServiceClient::RequestID.new,
                              ServiceClient::Logger.new,
                              ServiceClient::BodyEncoder.new(:json),
                            ],
                            raise_errors: true
                           )
