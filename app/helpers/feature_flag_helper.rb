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

  def fetch_feature_flags
    flags_from_service = FeatureFlagService::API::Api.features.get(community_id: @current_community.id).maybe[:features].or_else(Set.new)

    is_admin = Maybe(@current_user).is_admin?.or_else(false)
    temp_flags = ApplicationController.fetch_temp_flags(is_admin, params, session)

    session[:feature_flags] = temp_flags

    flags_from_service.union(temp_flags)
  end

  def search_engine
    use_external_search = Maybe(APP_CONFIG).external_search_in_use.map { |v| v == true || v.to_s.casecmp("true") == 0 }.or_else(false)
    use_external_search ? :zappy : :sphinx
  end

  def location_search_available
    search_engine == :zappy
  end

end
