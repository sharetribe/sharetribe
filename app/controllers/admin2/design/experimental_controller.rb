module Admin2::Design
  class ExperimentalController < Admin2::AdminBaseController

    def index
      features = NewLayoutViewUtils.features(@current_community.id,
                                             @current_user.id,
                                             @current_community.private,
                                             CustomLandingPage::LandingPageStore.enabled?(@current_community.id))
      render :index, locals: { community: @current_community,
                               feature_rels: NewLayoutViewUtils::FEATURE_RELS,
                               features: features }
    end

    def update_experimental
      enabled_for_user = Maybe(experimental_params[:enabled_for_user]).map { |f| NewLayoutViewUtils.enabled_features(f) }.or_else([])
      disabled_for_user = NewLayoutViewUtils.resolve_disabled(enabled_for_user)
      enabled_for_community = Maybe(experimental_params[:enabled_for_community]).map { |f| NewLayoutViewUtils.enabled_features(f) }.or_else([])
      disabled_for_community = NewLayoutViewUtils.resolve_disabled(enabled_for_community)
      response = update_feature_flags(community_id: @current_community.id, person_id: @current_user.id,
                                      user_enabled: enabled_for_user, user_disabled: disabled_for_user,
                                      community_enabled: enabled_for_community, community_disabled: disabled_for_community)
      if Maybe(response)[:success].or_else(false)
        flash[:notice] = t("layouts.notifications.community_updated")
      else
        flash[:error] = t("layouts.notifications.community_update_failed")
      end
      redirect_to admin2_design_experimental_index_path
    end

    private

    def experimental_params
      enabled_for_user = {}
      enabled_for_community = {}
      params[:feature].each do |key, value|
        if value == 'enabled_for_user'
          enabled_for_user[key] = 'true'
        end
        if value == 'enabled_for_community'
          enabled_for_community[key] = 'true'
          enabled_for_user[key] = 'true'
        end
      end
      { enabled_for_user: enabled_for_user,
        enabled_for_community: enabled_for_community }
    end

    def update_feature_flags(community_id:, person_id:, user_enabled:, user_disabled:, community_enabled:, community_disabled:)
      updates = []
      unless user_enabled.blank?
        updates << -> {
          FeatureFlagService::API::Api.features.enable(community_id: community_id, person_id: person_id, features: user_enabled)
        }
      end
      unless user_disabled.blank?
        updates << ->(*) {
          FeatureFlagService::API::Api.features.disable(community_id: @current_community.id, person_id: @current_user.id, features: user_disabled)
        }
      end
      unless community_enabled.blank?
        updates << ->(*) {
          FeatureFlagService::API::Api.features.enable(community_id: @current_community.id, features: community_enabled)
        }
      end
      unless community_disabled.blank?
        updates << ->(*) {
          FeatureFlagService::API::Api.features.disable(community_id: @current_community.id, features: community_disabled)
        }
      end
      Result.all(*updates)
    end

  end
end
