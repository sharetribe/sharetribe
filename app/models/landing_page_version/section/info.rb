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
      :columns
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

    def initialize(attributes={})
      super
      @kind = LandingPageVersion::Section::INFO
    end

    def attributes
      Hash[ATTRIBUTES.map {|x| [x, nil]}]
    end

    def removable?
      true
    end

    class << self
      def new_from_content(content_section)
        case content_section['variation']
        when LandingPageVersion::Section::VARIATION_SINGLE_COLUMN
          LandingPageVersion::Section::InfoSingleColumn.new(content_section)
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
