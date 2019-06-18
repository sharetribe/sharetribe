module CustomLandingPage
  class SectionService
    attr_reader :community, :params

    def initialize(community:, params:)
      @params = params
      @community = community
    end

    def landing_page_version
      @landing_page_version ||= landing_page_versions_scope.find(params[:landing_page_version_id])
    end

    def new_section
      section_from_params
      section.previous_id = nil
      section
    end

    def section
      @section ||= landing_page_version.sections.find{|x| x.id == params[:id]}
    end

    def create
      create_or_update
    end

    def update
      create_or_update(update: true)
    end

    def destroy
      section.destroy!
    end

    private

    def create_or_update(update: false)
      section_from_params
      section.update = update
      section.save
    end

    def landing_page_versions_scope
      LandingPageVersion.where(community: community)
    end

    def section_params
      params.require(:section).permit(
        :kind,
        :variation,
        :id,
        :previous_id,
        :title,
        :paragraph
      )
    end

    def section_from_params
      if section_params[:kind] == LandingPageVersion::Section::INFO
        @section = LandingPageVersion::Section::Info.new_from_content(section_params)
      end
      section.landing_page_version = landing_page_version
      section.id = params[:id] if params[:id].present?
      section
    end
  end
end
