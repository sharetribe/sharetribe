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
      super(attributes)
      @kind = LandingPageVersion::Section::HERO
      DEFAULTS.each do |key, value|
        unless self.send(key)
          self.send("#{key}=", value)
        end
      end
    end

    def attributes
      Hash[ATTRIBUTES.map {|x| [x, nil]}]
    end

    def removable?
      false
    end

    def asset_added(new_asset)
      assets = landing_page_version.parsed_content['assets']
      image_id = background_image['id']
      item = assets.find{|x| x['id'] == image_id }
      unless item
        item = {'id' => image_id}
        assets << item
      end
      blob = new_asset.blob
      item['src'] = blob_path(blob)
      item['content_type'] = blob.content_type
      item['absoulte_path'] = true
      item
    end

    class << self
      def new_from_content(content_section)
        new(content_section)
      end

      def permitted_params
        PERMITTED_PARAMS
      end
    end

    private

    def blob_path(blob)
      Rails.application.routes.url_helpers.landing_page_asset_path(signed_id: blob.signed_id, filename: blob.filename.to_s, sitename: landing_page_version.community.ident, only_path: true)
    end
  end
end
