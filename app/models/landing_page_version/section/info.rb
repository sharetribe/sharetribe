module LandingPageVersion::Section
  class Info < Base
    ATTRIBUTES = [
      :id,
      :kind,
      :variation,
      :title,
      :paragraph,
      :button_color,
      :button_color_hover,
      :button_title,
      :button_path,
      :background_image,
      :background_image_variation,
      :background_color,
      :icon_color,
      :columns,
      :paragraph_link_color,
      :paragraph_link_color_hover
    ].freeze

    PERMITTED_PARAMS = [
      :kind,
      :variation,
      :id,
      :previous_id,
      :title,
      :paragraph
    ].freeze

    attr_accessor(*(ATTRIBUTES + HELPER_ATTRIBUTES))

    attr_writer :background_style

    STYLE_IMAGE = 'image'
    STYLE_COLOR = 'color'
    STYLE_NONE = 'none'

    before_save :check_extra_attributes

    def initialize(attributes={})
      super
      @kind = LandingPageVersion::Section::INFO
    end

    def attributes
      Hash[ATTRIBUTES.map {|x| [x.to_s, nil]}]
    end

    def removable?
      true
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

      self.background_color = nil unless background_style == 'color'
      self.background_image = nil unless background_style == 'image'
    end

    def background_style
      @background_style ||=
        if background_image.present?
          STYLE_IMAGE
        elsif background_color.present?
          STYLE_COLOR
        else
          STYLE_NONE
        end
    end

    def cta_enabled
      return @cta_enabled if defined?(@cta_enabled)

      @cta_enabled = button_title.present?
    end

    def cta_enabled=(value)
      @cta_enabled = value != '0'
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

    class << self
      def new_from_content(content_section)
        case content_section['variation']
        when LandingPageVersion::Section::VARIATION_SINGLE_COLUMN
          LandingPageVersion::Section::InfoSingleColumn.new(content_section)
        when LandingPageVersion::Section::VARIATION_MULTI_COLUMN
          LandingPageVersion::Section::InfoMultiColumn.new(content_section)
        else
          new(content_section)
        end
      end

      def permitted_params
        PERMITTED_PARAMS
      end
    end
  end
end
