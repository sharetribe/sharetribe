module Admin2::SocialMedia
  class ImageTagsController < Admin2::AdminBaseController

    def index
      @customizations = @current_community.community_customizations
                                          .where(locale: @current_community.locales)
    end

    def update_image
      @current_community.update!(image_params)
      flash[:notice] = t('admin2.notifications.image_tags_updated')
    rescue StandardError => e
      flash[:error] = e.message
    ensure
      redirect_to admin2_social_media_image_tags_path
    end

    private

    def image_params
      params.require(:community).permit(community_customizations_attributes:
                                          %i[id social_media_title social_media_description],
                                        social_logo_attributes: %i[id image])
    end

  end
end
