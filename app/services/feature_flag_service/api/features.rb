module FeatureFlagService::API

  class Features

    def initialize(feature_flag_store)
      @feature_flag_store = feature_flag_store
    end

    # Enable features for a community or a person if person_id is provided.
    def enable(community_id:, person_id: nil, features:)
      if features.blank?
        return Result::Error.new("You must specify one or more flags in #{@feature_flag_store.known_flags} to enable.")
      end

      Result::Success.new(@feature_flag_store.enable(community_id, person_id, features))
    end

    # Disable features for a community or a person if person_id is provided.
    def disable(community_id:, person_id: nil, features:)
      if features.blank?
        return Result::Error.new("You must specify one or more flags in #{@feature_flag_store.known_flags} to disable.")
      end

      Result::Success.new(@feature_flag_store.disable(community_id, person_id, features))
    end

    # Fetch community-specific features or person-specific features if person_id is provided.
    def get(community_id:, person_id: nil)
      Result::Success.new(@feature_flag_store.get(community_id, person_id))
    end

    # Check if a feature is enabled for a community or a person.
    # Both checks are made by providing both id parameters.
    def enabled?(community_id:, person_id: nil, feature:)
      features =
        if person_id
          @feature_flag_store.get(community_id, person_id)[:features] + @feature_flag_store.get(community_id, nil)[:features]
        else
          @feature_flag_store.get(community_id, nil)[:features]
        end

      Result::Success.new(features.include?(feature))
    end
  end
end
