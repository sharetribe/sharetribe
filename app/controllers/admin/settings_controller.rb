class Admin::SettingsController < Admin::AdminBaseController
  before_action :set_selected_left_navi_link
  before_action :set_service

  def update
    if @service.update
      flash[:notice] = t("layouts.notifications.community_updated")
    else
      flash.now[:error] = t("layouts.notifications.community_update_failed")
    end
    render :show
  end

  private

  def set_selected_left_navi_link
    @selected_left_navi_link = 'admin_settings'
  end

  def set_service
    @service = Admin::SettingsService.new(
      community: @current_community,
      params: params)
    @presenter = Admin::SettingsPresenter.new(service: @service)
  end

end
