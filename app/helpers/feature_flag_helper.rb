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
    use_external_search = Maybe(APP_CONFIG).external_search_in_use.map { |v| v == true || v.to_s.casecmp("true") == 0 }.or_else(false)
    use_external_search ? :zappy : :sphinx
  end

  def location_search_available
    search_engine == :zappy
  end

end
