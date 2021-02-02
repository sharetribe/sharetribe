module Admin2::Design
  class LandingPageVersionsController < Admin2::AdminBaseController
    before_action :set_service
    before_action :ensure_plan

    def index

    end

    private

    def set_service
      @service = CustomLandingPage::EditorService.new(
          community: @current_community,
          params: params)
      @service.ensure_latest_version_exists!
      @presenter = CustomLandingPage::EditorPresenter.new(service: @service)
    end

    def ensure_plan
      @allowed_lp = @current_plan.try(:[], :features).try(:[], :landing_page)
    end
  end
end
