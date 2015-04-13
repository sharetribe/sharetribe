module FeatureFlagService::API

  class Features

    FeatureFlagStore = FeatureFlagService::Store::FeatureFlag

    def enable(community_id:, features:)
      if (features.blank?)
        return Result::Error.new("You must specify one or more flags in #{FeatureFlagStore.known_flags} to enable.")
      end

      Result::Success.new(FeatureFlagStore.enable(community_id, features))
    end

    def disable(community_id:, features:)
      if (features.blank?)
        return Result::Error.new("You must specify one or more flags in #{FeatureFlagStore.known_flags} to disable.")
      end

      Result::Success.new(FeatureFlagStore.disable(community_id, features))
    end

    def get(community_id:)
      Result::Success.new(FeatureFlagStore.get(community_id))
    end
  end
end
