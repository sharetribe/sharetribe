module Admin2::SearchLocation
  class SearchController < Admin2::AdminBaseController
    before_action :enabled_search, :set_service
    before_action :find_customizations, only: :index

    def index; end

    def update_search
      if @service.update
        render json: { message: t('admin2.notifications.search_updated') }
      else
        raise t('admin2.notifications.search_updated_failed')
      end
    rescue StandardError => e
      render json: { message: e.message }, status: 422
    end

    private

    def enabled_search
      return if FeatureFlagHelper.location_search_available

      redirect_to admin2_path
    end

    def set_service
      @service = Admin::SettingsService.new(
        community: @current_community,
        params: params)
      @presenter = Admin::SettingsPresenter.new(service: @service)
    end
  end
end
