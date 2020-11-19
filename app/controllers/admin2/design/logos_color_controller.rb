module Admin2::Design
  class LogosColorController < Admin2::AdminBaseController

    def index; end

    def update_logos_color
      @current_community.update!(logos_params)
      flash[:notice] = t('admin2.notifications.logos_updated')
    rescue StandardError => e
      flash[:error] = e.message
    ensure
      redirect_to admin2_design_logos_color_index_path
    end

    def remove_files
      case params[:type]
      when 'main_logo'
        @current_community.wide_logo.destroy
      when 'square_logo'
        @current_community.logo.destroy
      when 'favicon'
        @current_community.favicon.destroy
      when 'cover_photo'
        @current_community.cover_photo.destroy
      when 'small_cover_photo'
        @current_community.small_cover_photo.destroy
      when 'image_for_social_media'
        @current_community.social_logo.destroy
      end
      @current_community.save!
      @clp_enabled = clp_enabled
      flash[:notice] = t('admin2.notifications.file_was_deleted')
    rescue StandardError => e
      flash[:error] = e.message
    ensure
      redirect_back(fallback_location: admin2_path)
    end

    private

    def logos_params
      params.require(:community).permit(:custom_color1,
                                        :logo,
                                        :wide_logo,
                                        :favicon)
    end
  end
end
