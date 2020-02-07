module Admin2::SearchLocation
  class SearchController < Admin2::AdminBaseController
    before_action :enabled_search, :set_service
    before_action :find_customizations, only: :index

    def index; end

    def update_search
      if @service.update
        flash[:notice] = t('admin2.notifications.search_updated')
      else
        flash[:error] = t('admin2.notifications.search_updated_failed')
      end
      redirect_to admin2_search_location_search_index_path
    end

    private

    def enabled_search
      return if FeatureFlagHelper.location_search_available

      redirect_to admin2_dashboard_index_path
    end

    def set_service
      @service = Admin::SettingsService.new(
        community: @current_community,
        params: params)
      @presenter = Admin::SettingsPresenter.new(service: @service)
    end
  end
end
