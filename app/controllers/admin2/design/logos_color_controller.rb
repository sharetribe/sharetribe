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

    private

    def logos_params
      params.require(:community).permit(:custom_color1,
                                        :logo,
                                        :wide_logo,
                                        :favicon)
    end
  end
end
