class Admin::LandingPageVersions::SectionsController < Admin::AdminBaseController
  before_action :ensure_feature_flag
  before_action :set_selected_left_navi_link
  before_action :set_service

  def new
    @service.new_section
  end

  def create
    if @service.create
      redirect_to edit_admin_landing_page_version_path(@service.landing_page_version)
    else
      render :new
    end
  end

  def edit; end

  def update
    if @service.update
      redirect_to edit_admin_landing_page_version_path(@service.landing_page_version)
    else
      render :edit
    end
  end

  def destroy
    @service.destroy
    redirect_to edit_admin_landing_page_version_path(@service.landing_page_version)
  end

  private

  def set_selected_left_navi_link
    @selected_left_navi_link = "custom_landing_pages"
  end

  def set_service
    @service = CustomLandingPage::SectionService.new(
      community: @current_community,
      params: params)
    @presenter = CustomLandingPage::SectionPresenter.new(service: @service)
  end

  def ensure_feature_flag
    FeatureFlagHelper.feature_enabled?(:clp_editor)
  end
end
