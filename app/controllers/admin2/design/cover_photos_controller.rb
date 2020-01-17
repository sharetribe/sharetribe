module Admin2::Design
  class CoverPhotosController < Admin2::AdminBaseController

    def index; end

    def update_cover_photos
      @current_community.update!(cover_photos_params)
      flash[:notice] = t('admin2.notifications.cover_photos_updated')
    rescue StandardError => e
      flash[:error] = e.message
    ensure
      redirect_to admin2_design_cover_photos_path
    end

    private

    def cover_photos_params
      params.require(:community).permit(:cover_photo,
                                        :small_cover_photo)
    end
  end
end
