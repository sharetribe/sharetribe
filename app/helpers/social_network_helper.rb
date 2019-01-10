module SocialNetworkHelper
  def facebook_connect_in_use?
    community = Maybe(@current_community)

    (APP_CONFIG.fb_connect_id || community.facebook_connect_id.or_else(false)) &&
      !@facebook_merge &&
      community.facebook_connect_enabled?.or_else(false)
  end
end

