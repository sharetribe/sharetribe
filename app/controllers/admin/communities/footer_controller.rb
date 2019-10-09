class Admin::Communities::FooterController < Admin::AdminBaseController
  before_action :set_selected_left_navi_link
  before_action :set_service

  def update
    return if @service.plan_footer_disabled?

    if @service.update
      flash[:notice] = t('layouts.notifications.community_updated')
      redirect_to admin_footer_edit_path
    else
      flash.now[:error] = t('layouts.notifications.community_update_failed')
      render :edit
    end
  end

  private

  def set_selected_left_navi_link
    @selected_left_navi_link = 'footer'
  end

  def set_service
    @service = Admin::Communities::FooterService.new(
      community: @current_community,
      params: params,
      plan: @current_plan)
  end
end
