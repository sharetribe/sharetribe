module FeatureFlagHelper

  def feature_enabled?(feature_name)
    feature_flags.include? feature_name
  end

  def with_feature(feature_name, &block)
    block.call if feature_enabled?(feature_name)
  end

  def feature_flags
    @feature_flags ||= fetch_feature_flags # fetch_feature_flags is defined in ApplicationController
  end

end
