module LandingPageVersion::Section
  class InfoSingleColumn < Info

    DEFAULTS = {
      variation: "single_column",
      title: nil,
      background_image: nil,
      background_image_variation: nil,
      paragraph: nil,
      button_color: {
        type: "marketplace_data",
        id: "primary_color"
      },
      button_color_hover: {
        type: "marketplace_data",
        id: "primary_color_darken"
      },
      button_title: nil,
      button_path: nil,
      paragraph_link_color: { type: "marketplace_data", id: "primary_color" },
      paragraph_link_color_hover: { type: "marketplace_data", id: "primary_color_darken" }
    }

    EXTRA_PERMITTED_PARAMS = [
      :cta_enabled,
      :button_title,
      :button_path_string,
      :background_style,
      :background_color_string,
      :background_image_variation
    ]

    before_save :check_extra_attributes

    def initialize(attributes={})
      super(attributes)
      DEFAULTS.each do |key, value|
        unless self.send(key)
          self.send("#{key}=", value)
        end
      end
    end

    def background_color_string
      if background_color.is_a?(Array)
        background_color.map{|c| format("%02x", c) }.join("")
      else
        ""
      end
    end

    def background_color_string=(value)
      rgb = value.to_s.scan(/[0-9a-fA-F]{2}/).map{|c| c.to_i(16) }
      self.background_color = rgb.size == 3 ? rgb : nil
    end

    def check_extra_attributes
      unless cta_enabled
        self.button_title = nil
        self.button_path = nil
      end

      self.background_color = nil unless background_style == LandingPageVersion::Section::BACKGROUND_STYLE_COLOR
      self.background_image = nil unless background_style == LandingPageVersion::Section::BACKGROUND_STYLE_IMAGE
    end

    def background_style
      @background_style ||=
        if background_image.present?
          LandingPageVersion::Section::BACKGROUND_STYLE_IMAGE
        elsif background_color.present?
          LandingPageVersion::Section::BACKGROUND_STYLE_COLOR
        else
          LandingPageVersion::Section::BACKGROUND_STYLE_NONE
        end
    end

    def cta_enabled
      return @cta_enabled if defined?(@cta_enabled)

      @cta_enabled = button_title.present?
    end

    def cta_enabled=(value)
      @cta_enabled = value != '0' && value != false
    end

    def button_path_string=(value)
      self.button_path = {value: value}
    end

    def button_path_string
      button_path&.[]('value')
    end

    def asset_added(new_asset)
      self.background_image = {'type' => 'assets', 'id' => self.id+"_background_image"}
      add_or_replace_asset(new_asset, background_image['id'])
    end

    def i18n_key
      'info_single_column'
    end

    class << self
      def permitted_params
        LandingPageVersion::Section::Info::PERMITTED_PARAMS + EXTRA_PERMITTED_PARAMS
      end
    end
  end
end
