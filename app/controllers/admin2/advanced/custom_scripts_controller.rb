module Admin2::Advanced
  class CustomScriptsController < Admin2::AdminBaseController

    def index; end

    def update_script
      @current_community.update!(script_params)
      flash[:notice] = t('admin2.notifications.custom_script_updated')
    rescue StandardError => e
      flash[:error] = e.message
    ensure
      redirect_to admin2_advanced_custom_scripts_path
    end

    private

    def script_params
      params.require(:community).permit(:custom_head_script)
    end
  end
end
