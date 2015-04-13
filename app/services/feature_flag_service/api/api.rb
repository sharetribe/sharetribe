module FeatureFlagService::API
  class Api

    def self.features
      @features ||= FeatureFlagService::API::Features.new
    end

  end
end
