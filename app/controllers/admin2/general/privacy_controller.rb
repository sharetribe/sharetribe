module Admin2::General
  class PrivacyController < Admin2::AdminBaseController

    def index
      @community_customizations = find_or_initialize_customizations(@current_community.locales)
    end

    def update_privacy
      @current_community.update!(privacy_params)
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
  end
end
