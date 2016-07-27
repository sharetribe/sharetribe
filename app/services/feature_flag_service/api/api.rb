module FeatureFlagService::API
  class Api

    def self.communityFeatures
      @community_features ||= FeatureFlagService::API::Features.new(
        FeatureFlagService::Store::CachingCommunityFeatureFlag.new(additional_flags: []))
    end

  end
end
