module LandingPageVersion::Section
  class Hero < Base
    ATTRIBUTES = [
      :id,
      :kind,
      :variation,
      :title,
      :subtitle,
      :background_image,
      :background_image_variation,
      :search_button,
      :search_path,
      :search_placeholder,
      :search_location_with_keyword_placeholder,
      :signup_path,
      :signup_button,
      :search_button_color,
      :search_button_color_hover,
      :signup_button_color,
      :signup_button_color_hover
    ].freeze

    DEFAULTS = {
      id: "hero",
      kind: "hero",
      variation: {type: "marketplace_data", id: "search_type"},
      title: {type: "marketplace_data", id: "slogan"},
      subtitle: {type: "marketplace_data", id: "description"},
      background_image: {type: "assets", id: "default_hero_background"},
      background_image_variation: "dark",
      search_button: {type: "translation", id: "search_button"},
      search_path: {type: "path", id: "search"},
      search_placeholder: {type: "marketplace_data", id: "search_placeholder"},
      search_location_with_keyword_placeholder: {type: "marketplace_data", id: "search_location_with_keyword_placeholder"},
      signup_path: {type: "path", id: "signup"},
      signup_button: {type: "translation", id: "signup_button"},
      search_button_color: {type: "marketplace_data", id: "primary_color"},
      search_button_color_hover: {type: "marketplace_data", id: "primary_color_darken"},
      signup_button_color: {type: "marketplace_data", id: "primary_color"},
      signup_button_color_hover: {type: "marketplace_data", id: "primary_color_darken"}
    }.freeze

    PERMITTED_PARAMS = [
      :kind,
      :variation,
      :id,
      :previous_id,
      :background_image,
      :background_image_variation
    ].freeze

    attr_accessor(*(ATTRIBUTES + HELPER_ATTRIBUTES))

    BACKGROUND_VARIATION_DARK = 'dark'.freeze
    BACKGROUND_VARIATION_LIGHT = 'light'.freeze
    BACKGROUND_VARIATION_TRANSPARENT = 'transparent'.freeze

    def initialize(attributes={})
      super(DEFAULTS.merge(attributes))
      @kind = LandingPageVersion::Section::HERO
    end

    def attributes
      Hash[ATTRIBUTES.map {|x| [x, nil]}]
    end

    def removable?
      false
    end

    def asset_added(new_asset)
      assets = landing_page_version.parsed_content['assets']
      item = assets.find{|x| x['id'] == 'default_hero_background' }
      unless item
        item = {'id' => 'default_hero_background'}
        assets << item
      end
      item['src'] = new_asset.image_file_name
      item['content_type'] = new_asset.image_content_type
    end

    class << self
      def new_from_content(content_section)
        new(content_section)
      end

      def permitted_params
        PERMITTED_PARAMS
      end
    end
  end
end
