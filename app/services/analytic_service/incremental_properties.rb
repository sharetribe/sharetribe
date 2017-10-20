module AnalyticService
  class IncrementalProperties
    attr_accessor :properties, :user, :community

    def initialize(user:, community:)
      @user = user
      @properties = default_properties
      @community = community
    end

    def send_properties
      if changes?
        AnalyticService::API::Api.send_incremental_properties(person: user,
                                                              community: community,
                                                              properties: properties)
      end
    end

    private

    def default_properties
      raise NotImplementedError
    end

    def changes?
      properties.values.select{ |v| v > 0 }.any?
    end
  end
end
