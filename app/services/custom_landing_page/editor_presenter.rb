module CustomLandingPage
  class EditorPresenter
    private

    attr_reader :service

    public

    delegate :community, :params, :released_version, :landing_page_version,
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
          LandingPageVersions::Section::INFO,
          {data: { variation: LandingPageVersions::Section::VARIATION_SINGLE_COLUMN}}
        ],
        [
          I18n.t('admin.communities.landing_pages.sections.info_multi_column_2'),
          LandingPageVersions::Section::INFO,
          {data: { variation: LandingPageVersions::Section::VARIATION_MULTI_COLUMN, multi_columns: 2}}
        ],
        [
          I18n.t('admin.communities.landing_pages.sections.info_multi_column_3'),
          LandingPageVersions::Section::INFO,
          {data: { variation: LandingPageVersions::Section::VARIATION_MULTI_COLUMN, multi_columns: 3}}
        ],
        [
          I18n.t('admin.communities.landing_pages.sections.listings'),
          LandingPageVersions::Section::LISTINGS,
        ],
        [
          I18n.t('admin.communities.landing_pages.sections.categories'),
          LandingPageVersions::Section::CATEGORIES,
        ],
        [
          I18n.t('admin.communities.landing_pages.sections.locations'),
          LandingPageVersions::Section::LOCATIONS,
        ],
        [
          I18n.t('admin.communities.landing_pages.sections.video'),
          LandingPageVersions::Section::VIDEO,
        ]
      ]
    end

    def position_up_class(position, index)
      if position.removable?
        index == 2 ? 'disabled' : ''
      else
        'disabled'
      end
    end

    def position_down_class(position, index)
      if position.removable?
        index == positions_size - 1 ? 'disabled' : ''
      else
        'disabled'
      end
    end

    private

    def positions_size
      @positions_size ||= landing_page_version.section_positions.size
    end
  end
end
