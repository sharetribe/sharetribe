module Admin2::SearchLocation
  class LocationsController < Admin2::AdminBaseController
    before_action :enabled_search

    def index; end

    def update_location
      @current_community.update!(location_params)
      unless @current_community.show_location
        @current_community.apply_main_search_keyword!
      end
      flash[:notice] = t('admin2.notifications.location_updated')
    rescue StandardError => e
      flash[:error] = e.message
    ensure
      redirect_to admin2_search_location_locations_path
    end

    private

    def location_params
      params.require(:community).permit(:show_location, :fuzzy_location)
    end

    def enabled_search
      return if FeatureFlagHelper.location_search_available

      redirect_to admin2_dashboard_index_path
    end
  end
end
