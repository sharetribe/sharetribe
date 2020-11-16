module Admin2::Analytics
  class GoogleController < Admin2::AdminBaseController

    def index; end

    def update_google
      @current_community.update!(google_params)
      render json: { message: t('admin2.notifications.google_analytics_updated') }
    rescue StandardError => e
      render json: { message: e.message }, status: 422
    end

    private

    def google_params
      params.require(:community).permit(:google_analytics_key)
    end
  end
end
