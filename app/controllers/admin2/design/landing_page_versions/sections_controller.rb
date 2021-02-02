class Admin2::Design::LandingPageVersions::SectionsController < Admin2::AdminBaseController
  before_action :ensure_plan
  before_action :set_service

  def new
    @service.new_section
    render layout: false
  end

  def create
    @service.create
  rescue StandardError => e
    flash[:error] = e.message
  ensure
    redirect_to admin2_design_landing_page_versions_path
  end

  def edit
    render layout: false
  end

  def update
    @service.update
  rescue StandardError => e
    flash[:error] = e.message
  ensure
    redirect_to admin2_design_landing_page_versions_path
  end

  def destroy
    @service.destroy
    redirect_to admin2_design_landing_page_versions_path
  end

  private

  def set_service
    @service = CustomLandingPage::SectionService.new(
      community: @current_community,
      params: params)
    @presenter = CustomLandingPage::SectionPresenter.new(service: @service)
  end

  def ensure_plan
    unless @current_plan.try(:[], :features).try(:[], :landing_page)
      redirect_to admin_landing_page_path and return
    end
  end
end
