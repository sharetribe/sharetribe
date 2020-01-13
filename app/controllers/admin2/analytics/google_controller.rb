module Admin2::Analytics
  class GoogleController < Admin2::AdminBaseController

    def index; end

    def update_google
      @current_community.update!(google_params)
      flash[:notice] = t('admin2.notifications.google_analytics_updated')
    rescue StandardError => e
      flash[:error] = e.message
    ensure
      redirect_to admin2_analytics_google_index_path
    end

    private

    def google_params
      params.require(:community).permit(:google_analytics_key)
    end
  end
end
