module IntercomHelper

  module_function

  # Create a user_hash for Secure mode
  # https://docs.intercom.com/configure-intercom-for-your-product-or-site/staying-secure/enable-secure-mode-on-your-web-product
  def user_hash(user_id)
    secret = APP_CONFIG.admin_intercom_secure_mode_secret
    OpenSSL::HMAC.hexdigest('sha256', secret, user_id) if secret.present?
  end

  def admin_intercom_respond_enabled?
    #
    # Remove the feature flag helper when this is published to everyone
    #
    APP_CONFIG.admin_intercom_respond_enabled.to_s.casecmp("true") &&
      FeatureFlagHelper.feature_enabled?(:admin_intercom_respond)
  end

  def admin_intercom_app_id
    APP_CONFIG.admin_intercom_app_id
  end

  def in_admin_intercom_respond_test_group?
    ratio = (APP_CONFIG.admin_intercom_respond_test_group_ratio || 0).to_f

    Random.rand < ratio
  end

end
