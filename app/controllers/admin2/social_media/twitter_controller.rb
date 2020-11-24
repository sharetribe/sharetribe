module Admin2::SocialMedia
  class TwitterController < Admin2::AdminBaseController

    def index; end

    def update_twitter
      @current_community.update!(twitter_params)
      flash[:notice] = t('admin2.notifications.twitter_updated')
    rescue StandardError => e
      flash[:error] = e.message
    ensure
      redirect_to admin2_social_media_twitter_index_path
    end

    private

    def twitter_params
      params.require(:community).permit(:twitter_handle)
    end

  end
end
