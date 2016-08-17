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

    # Fetch features enabled for a community or a person
    def get(community_id: nil, person_id: nil)
      unless community_id && person_id
        return Result::Error.new("You must specify a community_id and a person_id for feature flag query.")
      end

      Result::Success.new(@feature_flag_store.get(community_id, person_id))
    end

    def get_for_person(community_id:, person_id:)
      unless community_id && person_id
        return Result::Error.new("You must specify a community_id and a person_id for feature flag query.")
      end

      Result::Success.new(@feature_flag_store.get_for_person(community_id, person_id))
    end

    def get_for_community(community_id:)
      unless community_id
        return Result::Error.new("You must specify a community_id for feature flag query.")
      end

      Result::Success.new(@feature_flag_store.get_for_community(community_id))
    end
  end
end
