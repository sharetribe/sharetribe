module Admin2::General
  class PrivacyController < Admin2::AdminBaseController

    def index
      @community_customizations = find_or_initialize_customizations(@current_community.locales)
    end

    def update_privacy
      @current_community.update!(privacy_params)
      update_privacy_translations
      flash[:notice] = t('admin2.notifications.privacy_updated')
    rescue StandardError => e
      flash[:error] = e.message
    ensure
      redirect_to admin2_general_privacy_index_path
    end

    private

    def privacy_params
      params.require(:community).permit(:private)
    end

    def update_privacy_translations
      analytic = AnalyticService::CommunityCustomizations.new(user: @current_user, community: @current_community)
      @current_community.locales.map do |locale|
        locale_params = params.require(:community_customizations).require(locale)
                              .permit(:private_community_homepage_content)
        customizations = find_or_initialize_customizations_for_locale(locale)
        customizations.assign_attributes(locale_params)
        analytic.process(customizations)
        customizations.update({})
      end
    end
  end
end
