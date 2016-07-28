module FeatureFlagService::API

  class Features

    def initialize(feature_flag_store)
      @feature_flag_store = feature_flag_store
    end

    def enable(entity_id:, features:)
      if features.blank?
        return Result::Error.new("You must specify one or more flags in #{@feature_flag_store.known_flags} to enable.")
      end

      Result::Success.new(@feature_flag_store.enable(entity_id, features))
    end

    def disable(entity_id:, features:)
      if features.blank?
        return Result::Error.new("You must specify one or more flags in #{@feature_flag_store.known_flags} to disable.")
      end

      Result::Success.new(@feature_flag_store.disable(entity_id, features))
    end

    def get(entity_id:)
      Result::Success.new(@feature_flag_store.get(entity_id))
    end

    def enabled?(entity_id:, feature:)
      if entity_id
        Result::Success.new(@feature_flag_store.get(entity_id)[:features].include?(feature))
      else
        Result::Success.new(false)
      end
    end
  end
end
