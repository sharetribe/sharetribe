module IntercomHelper

  module_function

  def admin_intercom_respond_enabled?
    #
    # Remove the feature flag helper when this is published to everyone
    #
    APP_CONFIG.admin_intercom_respond_enabled.to_s.downcase == "true" &&
      FeatureFlagHelper.feature_enabled?(:admin_intercom_respond)
  end

  def admin_intercom_app_id
    APP_CONFIG.admin_intercom_app_id
  end

  def in_test_group?
    ratio = (APP_CONFIG.admin_intercom_respond_test_group_ratio || 0).to_f

    Random.rand < ratio
  end

end
