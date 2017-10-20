module AnalyticService
  module API
    class Api
      class << self
        def send_event(person:, community:, event_data:)
          AnalyticService::API::Intercom.send_event(person: person,
                                                    community: community,
                                                    event_data: event_data)
        end

        def send_incremental_properties(person:, community:, properties:)
          AnalyticService::API::Intercom.send_incremental_properties(person: person,
                                                                     community: community,
                                                                     properties: properties)
        end
      end
    end
  end
end
