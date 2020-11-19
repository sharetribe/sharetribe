module Admin2::Design
  class LogosColorController < Admin2::AdminBaseController

    def index; end

    def update_logos_color
      @current_community.update!(logos_params)
      render layout: false
    rescue StandardError => e
      @error = e.message
      render layout: false, status: :unprocessable_entity
    end

    def remove_files
      @type = params[:type]
      case @type
      when 'main_logo'
        @current_community.wide_logo.destroy
      when 'square_logo'
        @current_community.logo.destroy
      when 'favicon'
        @current_community.favicon.destroy
      when 'main_cover_photo'
        @current_community.cover_photo.destroy
      when 'small_cover_photo'
        @current_community.small_cover_photo.destroy
      when 'image_for_social_media'
        @current_community.social_logo.destroy
      end
      @current_community.save!
      @clp_enabled = clp_enabled
    rescue StandardError => e
      @error = e.message
    ensure
      render layout: false
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
