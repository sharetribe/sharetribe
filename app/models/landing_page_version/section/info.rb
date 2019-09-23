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

    def asset_added(new_asset)
      self.background_image = {'type' => 'assets', 'id' => self.id+"_background_image"}
      add_or_replace_asset(new_asset, background_image['id'], BACKGROUND_RESIZE_OPTIONS)
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
