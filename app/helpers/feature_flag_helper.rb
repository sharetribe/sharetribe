# These methods are intended to be called statically
# Call init first to initialize the state for the request
module FeatureFlagHelper

  class FeatureFlagNotEnabledError < StandardError; end
  class FeatureFlagHelperNotInitialized < StandardError; end

  module_function

  def init(community_id:, user_id:, request:, is_admin:, is_marketplace_admin:)
    RequestStore.store[:feature_flags] ||= fetch_feature_flags(community_id, user_id, request, is_admin, is_marketplace_admin)
  end

  def feature_enabled?(feature_name)
    feature_flags.include? feature_name
  end

  def assert_feature_enabled(feature_name)
    raise FeatureFlagNotEnabledError.new("Missing required feature: #{feature_name}") unless feature_enabled?(feature_name)
  end

  def with_feature(feature_name, &block)
    block.call if feature_enabled?(feature_name)
  end

  def feature_flags
    unless RequestStore.store[:feature_flags]
      raise FeatureFlagHelperNotInitialized.new("Feature flags helper not initialized! Call 'init' first.")
    end
    RequestStore.store[:feature_flags]
  end

  def fetch_feature_flags(community_id, person_id, request, is_admin, is_marketplace_admin)
    flags_from_service = fetch_flags_from_service(community_id, person_id, is_admin, is_marketplace_admin)
    temp_flags = fetch_temp_flags(is_admin, request.params, request.session)

    request.session[:feature_flags] = temp_flags

    flags_from_service.union(temp_flags)
  end

  def fetch_flags_from_service(community_id, person_id, is_admin, is_marketplace_admin)
    # for admin users fetch combined feature flags,
    # for non-admin users only fetch the community specific feature flags
    if person_id && (is_admin || is_marketplace_admin)
      FeatureFlagService::API::Api.features.get(community_id: community_id, person_id: person_id).maybe[:features].or_else(Set.new)
    else
      FeatureFlagService::API::Api.features.get_for_community(community_id: community_id).maybe[:features].or_else(Set.new)
    end
  end

  # Fetch temporary flags from params and session
  def fetch_temp_flags(is_admin, params, session)
    return Set.new unless is_admin

    from_session = Maybe(session)[:feature_flags].or_else(Set.new)
    from_params = Maybe(params)[:enable_feature].map { |feature| [feature.to_sym] }.to_set.or_else(Set.new)

    from_session.union(from_params)
  end

  def search_engine
    if APP_CONFIG.external_search_in_use.to_s.casecmp("true").zero?
      :zappy
    else
      :sphinx
    end
  end

  def location_search_available
    search_engine == :zappy
  end
end
