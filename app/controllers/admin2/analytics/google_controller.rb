module Admin2::Analytics
  class GoogleController < Admin2::AdminBaseController

    def index; end

    def update_google
      check_google_analytics_key
      @current_community.update!(google_params)
      render json: { message: t('admin2.notifications.google_analytics_updated') }
    rescue StandardError => e
      render json: { message: e.message }, status: :unprocessable_entity
    end

    private

    def check_google_analytics_key
      code = params[:community][:google_analytics_key]
      raise t('admin2.google.error_text') if code.present? && !code.start_with?('UA-')
    end

    def google_params
      params.require(:community).permit(:google_analytics_key)
    end
  end
end
