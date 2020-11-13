module Admin2::SearchLocation
  class LocationsController < Admin2::AdminBaseController
    before_action :enabled_search

    def index; end

    def update_location
      @current_community.update!(location_params)
      unless @current_community.show_location
        @current_community.apply_main_search_keyword!
      end
      render json: { message: t('admin2.notifications.location_updated') }
    rescue StandardError => e
      render json: { message: e.message }, status: :unprocessable_entity
    end

    private

    def location_params
      params.require(:community).permit(:show_location, :fuzzy_location)
    end

    def enabled_search
      return if FeatureFlagHelper.location_search_available

      redirect_to admin2_path
    end
  end
end
