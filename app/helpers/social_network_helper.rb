module SocialNetworkHelper
  def facebook_connect_in_use?
    community = Maybe(@current_community)

    (APP_CONFIG.fb_connect_id || community.facebook_connect_id.or_else(false)) &&
      !@facebook_merge &&
      community.facebook_connect_enabled?.or_else(false)
  end

  def google_connect_in_use?
    FeatureFlagHelper.feature_enabled?(:login_google_linkedin) &&
      @current_community && @current_community.google_connect_enabled? && @current_community.google_connect_id
  end
end

