module CustomLandingPage
  class EditorService
    attr_reader :community, :params

    def initialize(community:, params:)
      @params = params
      @community = community
    end

    def landing_page_versions
      landing_page_versions_scope.paginate(:page => params[:page], :per_page => 30)
    end

    def new_landing_page_version
      @landing_page_version = landing_page_versions_scope.new(content: CustomLandingPage::ExampleData::DATA_STR)
    end

    def create_landing_page_version
      @landing_page_version = landing_page_versions_scope.create(landing_page_version_params)
    end

    def release_landing_page_version
      version = landing_page_version.version
      landing_page = landing_pages_scope.enabled.first_or_create
      landing_page.released_version = version
      landing_page.save
    end

    def landing_page_version
      @landing_page_version ||= landing_page_versions_scope.find(params[:id])
    end

    def errors?
      @landing_page_version.errors.any?
    end

    def released_version
      @released_version ||= landing_pages_scope.enabled.pluck(:released_version).first
    end

    private

    def landing_page_versions_scope
      LandingPageVersion.where(community: community)
    end

    def landing_pages_scope
      LandingPage.where(community: community)
    end

    def landing_page_version_params
      params.require(:landing_page_version).permit(
        :version,
        :content)
    end
  end
end
