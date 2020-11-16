module Admin2::Design
  class CoverPhotosController < Admin2::AdminBaseController

    def index; end

    def update_cover_photos
      @current_community.update!(cover_photos_params)
      render layout: false
    rescue StandardError => e
      @error = e.message
      render layout: false, status: 422
    end

    private

    def cover_photos_params
      params.require(:community).permit(:cover_photo,
                                        :small_cover_photo)
    end
  end
end
