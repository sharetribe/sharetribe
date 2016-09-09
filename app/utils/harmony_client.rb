HarmonyClient =
  ServiceClient::Client.new("http://localhost:8085",
                            {
                              query_time_slots: "/timeslots/query",
                              create_bookable: "/bookables/create",
                            },
                            [
                              ServiceClient::Middleware::RequestID.new,
                              ServiceClient::Middleware::Logger.new,
                              ServiceClient::Middleware::BodyEncoder.new(:transit_msgpack),
                            ],
                            raise_errors: true
                           )

# Usage example:
#
# > marketplace_id, ref_id, author_id = (1..3).map { SecureRandom.uuid }
#
# > HarmonyClient.post(:create_bookable, body: { marketplaceId: marketplace_id, refId: ref_id, authorId: author_id })
# > HarmonyClient.get(:query_time_slots, params: { refIds: [ref_id], marketplaceId: marketplace_id, start: <time, what's the format?>, end: <time, what's the format?> })
