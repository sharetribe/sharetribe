module FeatureFlagHelper

  def feature_enabled?(feature_name)
    feature_flags.include? feature_name
  end

  def with_feature(feature_name, &block)
    block.call if feature_enabled?(feature_name)
  end

  def feature_flags
    @feature_flags ||= FeatureFlagService::API::Api.features.get(community_id: @current_community.id).maybe[:features].or_else(Set.new)
  end

end
