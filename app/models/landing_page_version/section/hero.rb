module LandingPageVersion::Section
  class Hero < Base
    ATTRIBUTES = [ # abc
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
      :signup_button_color_hover,
      :cta_button_type,
      :button_title,
      :button_path,
    ].freeze
    BUTTON_TYPE_DEFAULT = 'default'.freeze
    BUTTON_TYPE_BUTTON = 'button'.freeze
    BUTTON_TYPE_NONE = 'none'.freeze

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
      signup_button_color_hover: {type: "marketplace_data", id: "primary_color_darken"},
      cta_button_type: BUTTON_TYPE_DEFAULT,
      button_title: nil,
      button_path: nil
    }.freeze

    PERMITTED_PARAMS = [
      :kind,
      :variation,
      :id,
      :previous_id,
      :background_image,
      :background_image_variation,
      :cta_button_type,
      :cta_button_text,
      :cta_button_url
    ].freeze

    attr_accessor(*(ATTRIBUTES + HELPER_ATTRIBUTES))

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
      Hash[ATTRIBUTES.map {|x| [x.to_s, nil]}]
    end

    def removable?
      false
    end

    def asset_added(new_asset)
      add_or_replace_asset(new_asset, background_image['id'], BACKGROUND_RESIZE_OPTIONS)
    end

    def i18n_key
      'hero'
    end

    def cta_button_text
      button_title&.[]('value')
    end

    def cta_button_text=(value)
      self.button_title = {value: value}
    end

    def cta_button_url
      button_path&.[]('value')
    end

    def cta_button_url=(value)
      self.button_path = {value: value}
    end

    def cta_button_type_button?
      cta_button_type == BUTTON_TYPE_BUTTON
    end

    def cta_button_type_none?
      cta_button_type == BUTTON_TYPE_NONE
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
