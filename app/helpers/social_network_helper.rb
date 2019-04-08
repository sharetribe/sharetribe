module SocialNetworkHelper
  def facebook_connect_in_use?
    community = Maybe(@current_community)

    (APP_CONFIG.fb_connect_id || community.facebook_connect_id.or_else(false)) &&
      !@facebook_merge &&
      community.facebook_connect_enabled?.or_else(false)
  end

  def google_connect_in_use?
    @current_community&.google_connect_enabled? && @current_community&.google_connect_id
  end

  def linkedin_connect_in_use?
    @current_community&.linkedin_connect_enabled? && @current_community&.linkedin_connect_id
  end
end

