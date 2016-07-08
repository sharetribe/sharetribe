# A module intended to be used as a mixin with controllers whose
# actions / views want to access information about feature flags.
module FeatureFlagHelper

  class FeatureFlagNotEnabledError < StandardError; end

  def self.included(target)
    target.include InstanceMethods
    target.extend ClassMethods
  end

  module InstanceMethods
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
      RequestStore.store[:feature_flags] ||= fetch_feature_flags
    end

    def fetch_feature_flags
      flags_from_service = FeatureFlagService::API::Api.features.get(community_id: community_id(request)).maybe[:features].or_else(Set.new)

      is_admin = called_with_admin_user?
      temp_flags = fetch_temp_flags(is_admin, request.params, request.session)

      request.session[:feature_flags] = temp_flags

      flags_from_service.union(temp_flags)
    end

    # Fetch temporary flags from params and session
    def fetch_temp_flags(is_admin, params, session)
      return Set.new unless is_admin

      from_session = Maybe(session)[:feature_flags].or_else(Set.new)
      from_params = Maybe(params)[:enable_feature].map { |feature| [feature.to_sym] }.to_set.or_else(Set.new)

      from_session.union(from_params)
    end

    def community_id(request)
      request.env[:current_marketplace].id
    end

    # If the including controller defines @current_user we use it to
    # determine if the method is being called with an admin
    # user. Otherwise we assume that's not the case. The @current_user
    # should be made available in request.env similarly to marketplace
    # to make this functionality portable outside
    # ApplicationController inheritance hierarchy.
    def called_with_admin_user?
      Maybe(@current_user).is_admin?.or_else(false)
    end

    def search_engine
      use_external_search = Maybe(APP_CONFIG).external_search_in_use.map { |v| v == true || v.to_s.casecmp("true") == 0 }.or_else(false)
      use_external_search ? :zappy : :sphinx
    end

    def location_search_available
      search_engine == :zappy
    end
  end

  module ClassMethods
    # Add a before filter that asserts given feature flag is set.
    #
    # Usage:
    #
    # class YourController < ApplicationController
    #   ensure_feature_enabled :shipping, only: [:new_shipping, :edit_shipping]
    #   ...
    #  end
    #
    def ensure_feature_enabled(feature_name, options = {})
      before_filter(options) { assert_feature_enabled(feature_name) }
    end
  end

end
