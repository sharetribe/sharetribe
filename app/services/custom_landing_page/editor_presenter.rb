module CustomLandingPage
  class EditorPresenter
    private

    attr_reader :service

    public

    delegate :community, :params, :landing_page_versions, :released_version,
      :landing_page_version,
      to: :service, prefix: false, allow_nil: false

    def initialize(service:)
      @service = service
    end

    def released?(landing_page_version)
      landing_page_version.version == released_version
    end

    def section_dropdown_options
      [
        [
          I18n.t('admin.communities.landing_pages.sections.info_single_column'),
          LandingPageVersion::Section::INFO,
          {data: { variation: LandingPageVersion::Section::VARIATION_SINGLE_COLUMN}}
        ]
      ]
    end
  end
end
