module LandingPageVersion::Section
  class Video < Base
    ATTRIBUTES = [
      :id,
      :kind,
      :variation,
      :width,
      :height,
      :text,
      :youtube_video_id,
      :autoplay
    ].freeze

    PERMITTED_PARAMS = [
      :id,
      :kind,
      :variation,
      :previous_id,
      :text,
      :youtube_video_id,
      :autoplay
    ].freeze

    DEFAULTS = {
      id: nil,
      kind: "video",
      variation: "youtube",
      youtube_video_id: nil,
      width: "1280",
      height: "720",
      text: nil,
      autoplay: false
    }

    AUTOPLAY_NO = 'no'.freeze
    AUTOPLAY_MUTED = 'muted'.freeze

    attr_accessor(*(ATTRIBUTES + HELPER_ATTRIBUTES))

    def initialize(attributes={})
      super
      @kind = LandingPageVersion::Section::VIDEO
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
      true
    end

    def autoplay=(value)
      @autoplay = if value.blank? || ['0', false, 'false', 'no'].include?(value)
        false
      else
        value
      end
    end

    def i18n_key
      'video'
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
