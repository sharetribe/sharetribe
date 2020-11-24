module Admin2::Analytics
  class SharetribeController < Admin2::AdminBaseController
    before_action :check_admin_enable_tracking

    def index; end

    def update_sharetribe
      @current_community.update!(sharetribe_params)
      flash[:notice] = t('admin2.notifications.sharetribe_analytics_updated')
    rescue StandardError => e
      flash[:error] = e.message
    ensure
      redirect_to admin2_analytics_sharetribe_index_path
    end

    private

    def check_admin_enable_tracking
      return if APP_CONFIG.admin_enable_tracking_config

      redirect_to admin2_dashboard_index_path
    end

    def sharetribe_params
      params.require(:community).permit(:end_user_analytics)
    end
  end
end
