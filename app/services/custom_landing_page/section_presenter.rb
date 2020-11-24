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

    def section_categories?
      section.is_a?(LandingPageVersion::Section::Categories)
    end

    def section_locations?
      section.is_a?(LandingPageVersion::Section::Locations)
    end

    def section_video?
      section.is_a?(LandingPageVersion::Section::Video)
    end

    def section_errors?
      section.errors.any?
    end

    def section_errors
      section.errors.full_messages.join(', ')
    end

    def id_error?
      section.errors.key?(:id)
    end

    def section_background_image_present?
      section_background_image.present?
    end

    def section_background_image_url
      section_background_image['src']
    end

    def section_background_image_filename
      filename(section_background_image)
    end

    def section_background_image
      return nil unless section&.background_image
      return @section_background_image if defined?(@section_background_image)

      @section_background_image = asset_resolver.call('assets', section.background_image['id'], landing_page_version.parsed_content)
    end

    def categories_for_select(locale)
      return @categories_tree if defined?(@categories_tree)

      @categories_tree = []
      padding = "\u00A0" * 4
      categories = community.top_level_categories.includes(:translations, children: :translations)
      categories.each do |category|
        @categories_tree << [category.display_name(locale), category.id]
        category.children.each do |subcategory|
          @categories_tree << [padding + subcategory.display_name(locale).to_s, subcategory.id]
        end
      end
      @categories_tree
    end

    def category_image(index)
      return nil unless section.categories[index]

      asset_id = section.categories[index].asset_id
      return nil if asset_id.nil?

      asset_resolver.call('assets', asset_id, landing_page_version.parsed_content)
    end

    def category_image_url(index)
      category_image(index)['src']
    end

    def category_image_filename(index)
      filename(category_image(index))
    end

    def location_image(index)
      return nil unless section.locations[index]

      asset_id = section.locations[index].asset_id
      return nil if asset_id.nil?

      asset_resolver.call('assets', asset_id, landing_page_version.parsed_content)
    end

    def location_image_url(index)
      location_image(index)['src']
    end

    def location_image_filename(index)
      filename(location_image(index))
    end

    private

    def asset_resolver
      @asset_resolver ||= CustomLandingPage::LinkResolver::AssetResolver.new(APP_CONFIG[:clp_asset_url], community.ident)
    end

    def filename(item)
      ActiveStorage::Blob.find_by(id: item['asset_id']).try(:filename).to_s
    end
  end
end
