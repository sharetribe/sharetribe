module CustomLandingPage
  class SectionPresenter
    private

    attr_reader :service

    public

    delegate :community, :params, :landing_page_version, :section,
      to: :service, prefix: false, allow_nil: false

    def initialize(service:)
      @service = service
    end

    def section_info_single_column?
      section.is_a?(LandingPageVersion::Section::InfoSingleColumn)
    end

    def section_hero?
      section.is_a?(LandingPageVersion::Section::Hero)
    end

    def section_footer?
      section.is_a?(LandingPageVersion::Section::Footer)
    end

    def section_errors?
      section.errors.any?
    end

    def section_errors
      section.errors.full_messages.join(', ')
    end
  end
end
