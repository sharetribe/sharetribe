module Admin2::SocialMedia
  class SocialShareButtonsController < Admin2::AdminBaseController

    def index; end

    def update_share_buttons
      @current_community.update!(share_buttons_params) unless @current_community.social_share_buttons_disabled?
      render json: { message: t('admin2.notifications.social_share_buttons_updated') }
    rescue StandardError => e
      render json: { message: e.message }, status: :unprocessable_entity
    end

    private

    def share_buttons_params
      params.require(:community).permit(:enable_social_share_buttons)
    end
  end
end
