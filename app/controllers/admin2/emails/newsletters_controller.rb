module Admin2::Emails
  class NewslettersController < Admin2::AdminBaseController

    def index; end

    def update_newsletter
      @current_community.update!(newsletters_params)
      render json: { message: t('admin2.notifications.newsletters_updated') }
    rescue StandardError => e
      render json: { message: e.message }, status: 422
    end

    private

    def newsletters_params
      params.require(:community).permit(:automatic_newsletters,
                                        :default_min_days_between_community_updates)
    end
  end
end
