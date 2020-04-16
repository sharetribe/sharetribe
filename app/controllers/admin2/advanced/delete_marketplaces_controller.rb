module Admin2::Advanced
  class DeleteMarketplacesController < Admin2::AdminBaseController
    before_action :set_service

    def index; end

    def destroy
      if @presenter.can_delete_marketplace && params[:delete_confirmation] == @current_community.ident
        @current_community.update(deleted: true)

        redirect_to Maybe(APP_CONFIG.community_not_found_redirect).or_else(:community_not_found)
      else
        flash[:error] = t('admin2.delete_marketplace.cannot_delete')
        redirect_to admin2_advanced_delete_marketplaces_path
      end
    end

    private

    def set_service
      @service = Admin::SettingsService.new(
        community: @current_community,
        params: params)
      @presenter = Admin::SettingsPresenter.new(service: @service)
    end
  end
end
