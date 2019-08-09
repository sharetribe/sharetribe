class Admin::LandingPageVersions::SectionsController < Admin::AdminBaseController
  before_action :ensure_feature_flag
  before_action :allow_attachment_params
  before_action :set_selected_left_navi_link
  before_action :set_service

  def new
    @service.new_section
  end

  def create
    if @service.create
      redirect_to admin_landing_page_versions_path
    else
      render :new
    end
  end

  def edit; end

  def update
    if @service.update
      redirect_to admin_landing_page_versions_path
    else
      render :edit
    end
  end

  def destroy
    @service.destroy
    redirect_to admin_landing_page_versions_path
  end

  private

  def set_selected_left_navi_link
    @selected_left_navi_link = "landing_page"
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

  def allow_attachment_params
    valid_types = ActionController::Parameters::PERMITTED_SCALAR_TYPES
    new_type = ActiveStorage::Attachment
    valid_types << new_type unless valid_types.include?(new_type)
  end
end
