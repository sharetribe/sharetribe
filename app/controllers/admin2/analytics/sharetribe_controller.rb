module Admin2::Analytics
  class SharetribeController < Admin2::AdminBaseController
    before_action :check_admin_enable_tracking

    def index; end

    def update_sharetribe
      @current_community.update!(sharetribe_params)
      render json: { message: t('admin2.notifications.sharetribe_analytics_updated') }
    rescue StandardError => e
      render json: { message: e.message }, status: 422
    end

    private

    def check_admin_enable_tracking
      return if APP_CONFIG.admin_enable_tracking_config

      redirect_to admin2_path
    end

    def sharetribe_params
      params.require(:community).permit(:end_user_analytics)
    end
  end
end
