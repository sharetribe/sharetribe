class Admin::LandingPageVersionsController < Admin::AdminBaseController
  before_action :ensure_feature_flag
  before_action :set_selected_left_navi_link
  before_action :set_service

  def index
  end

  def release
    @service.release_landing_page_version
    redirect_to admin_landing_page_versions_path
  end

  private

  def set_selected_left_navi_link
    @selected_left_navi_link = "custom_landing_pages"
  end

  def set_service
    @service = CustomLandingPage::EditorService.new(
      community: @current_community,
      params: params)
    @presenter = CustomLandingPage::EditorPresenter.new(service: @service)
  end

  def ensure_feature_flag
    FeatureFlagHelper.feature_enabled?(:clp_editor)
  end
end
