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

  def search_engine
    feature_enabled?(:new_search) || APP_CONFIG.external_search_in_use ? :zappy : :sphinx
  end

  def location_search_available
    feature_enabled?(:location_search) && search_engine == :zappy
  end

end
