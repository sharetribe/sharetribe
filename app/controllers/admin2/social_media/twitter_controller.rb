module Admin2::SocialMedia
  class TwitterController < Admin2::AdminBaseController

    def index; end

    def update_twitter
      @current_community.update!(twitter_params)
      render json: { message: t('admin2.notifications.twitter_updated') }
    rescue StandardError => e
      render json: { message: e.message }, status: 422
    end

    private

    def twitter_params
      params.require(:community).permit(:twitter_handle)
    end

  end
end
