module AnalyticsHelper
  def analytics_data
    user_is_admin = @current_user.try(:is_marketplace_admin?, @current_community)
    {
      community_ident:  @current_community.try(:ident),
      community_uuid:   @current_community.try(:uuid_object).to_s,
      community_id:     @current_community.try(:id),
      community_admin_email: (user_is_admin ? IntercomHelper.email(@current_user) : nil),

      user_id:          @current_user.try(:id),
      user_uuid:        @current_user.try(:uuid_object).to_s,
      user_is_admin:    user_is_admin,
      user_email:       @current_user && IntercomHelper.email(@current_user) || 'null',
      user_name:        @current_user && @current_community && PersonViewUtils.person_display_name(@current_user, @current_community) || 'null',
      user_hash:        @current_user && IntercomHelper.user_hash(@current_user.uuid_object.to_s) || 'null',

      feature_flags:    FeatureFlagHelper.feature_flags,

      plan_status:        @current_plan && @current_plan[:status] || 'null',
      plan_member_limit:  @current_plan && @current_plan[:member_limit] || 'null',
      plan_created_at:    @current_plan && @current_plan[:created_at].to_time.to_i || 'null',
      plan_updated_at:    @current_plan && @current_plan[:updated_at].to_time.to_i || 'null',
      plan_expires_at:    @current_plan && @current_plan[:expires_at]&.to_time&.to_i,
      plan_features:      @current_plan && @current_plan[:features].select { |_, v| v }.keys.join(", ") || 'null',

      identity_information: @current_user ? IntercomHelper.identity_information(@current_user) : 'null'
    }
  end
end
