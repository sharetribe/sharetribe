module Admin2::General
  class PrivacyController < Admin2::AdminBaseController

    def index
      @community_customizations = find_or_initialize_customizations(@current_community.locales)
    end

    def update_privacy
      @current_community.update!(privacy_params)
      render json: { message: t('admin2.notifications.privacy_updated') }
    rescue StandardError => e
      render json: { message: e.message }, status: 422
    end

    private

    def privacy_params
      params.require(:community).permit(:private)
    end
  end
end
