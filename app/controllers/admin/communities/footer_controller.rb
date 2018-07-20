class Admin::Communities::FooterController < Admin::AdminBaseController
  before_action :ensure_feature_flag_enabled
  before_action :set_selected_left_navi_link
  before_action :set_service

  def update
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
      params: params)
  end

  def ensure_feature_flag_enabled
    unless pro_plan? && FeatureFlagHelper.feature_enabled?(:footer)
      redirect_to search_path and return
    end
  end
end
