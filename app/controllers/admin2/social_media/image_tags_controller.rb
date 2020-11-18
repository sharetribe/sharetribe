module Admin2::SocialMedia
  class ImageTagsController < Admin2::AdminBaseController
    before_action :find_customizations, only: :index

    def index; end

    def update_image
      @current_community.update!(image_params)
      render layout: false
    rescue StandardError => e
      @error = e.message
      render layout: false, status: :unprocessable_entity
    end

    private

    def image_params
      params.require(:community).permit(community_customizations_attributes:
                                          %i[id social_media_title social_media_description],
                                        social_logo_attributes: %i[id image])
    end

  end
end
