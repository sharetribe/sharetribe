module FeatureFlagService::API

  class Features

    def initialize(feature_flag_store)
      @feature_flag_store = feature_flag_store
    end

    def enable(community_id:, features:)
      if (features.blank?)
        return Result::Error.new("You must specify one or more flags in #{@feature_flag_store.known_flags} to enable.")
      end

      Result::Success.new(@feature_flag_store.enable(community_id, features))
    end

    def disable(community_id:, features:)
      if (features.blank?)
        return Result::Error.new("You must specify one or more flags in #{@feature_flag_store.known_flags} to disable.")
      end

      Result::Success.new(@feature_flag_store.disable(community_id, features))
    end

    def get(community_id:)
      Result::Success.new(@feature_flag_store.get(community_id))
    end
  end
end
