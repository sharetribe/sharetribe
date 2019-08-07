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

    def section_info_multi_column?
      section.is_a?(LandingPageVersion::Section::InfoMultiColumn)
    end

    def section_hero?
      section.is_a?(LandingPageVersion::Section::Hero)
    end

    def section_footer?
      section.is_a?(LandingPageVersion::Section::Footer)
    end

    def section_listings?
      section.is_a?(LandingPageVersion::Section::Listings)
    end

    def section_errors?
      section.errors.any?
    end

    def section_errors
      section.errors.full_messages.join(', ')
    end

    def id_error?
      section.errors.has_key?(:id)
    end

    def section_background_image_present?
      section_background_image.present?
    end

    def section_background_image_url
      section_background_image['src']
    end

    def section_background_image_filename
      section_background_image['src'].split('/').last
    end

    def section_background_image
      return nil unless section&.background_image
      return @section_background_image if defined?(@section_background_image)

      @section_background_image = asset_resolver.call('assets', section.background_image['id'], landing_page_version.parsed_content)
    end

    private

    def asset_resolver
      @asset_resolver ||= CustomLandingPage::LinkResolver::AssetResolver.new('', community.ident)
    end
  end
end
