module LandingPageVersion::Section
  class Footer < Base

    class SocialLink
      include ActiveModel::Model

      ATTRIBUTES = [
        :id,
        :provider,
        :url,
        :sort_priority,
        :enabled
      ]

      attr_accessor(*ATTRIBUTES)

      def enabled?
        enabled != '0' && enabled != false
      end

      def self.from_serialized_hash(link, index)
        self.new(
          id: link['service'],
          provider: link['service'],
          url: link['url'],
          sort_priority: index,
          enabled: link['enabled'].nil? || link['enabled'] == true)
      end

      def serializable_hash(options = nil)
        { service: id, url: url, enabled: enabled? }
      end
    end

    class MenuLink
      include ActiveModel::Model

      ATTRIBUTES = [
        :id,
        :title,
        :url,
        :sort_priority,
        :_destroy
      ]

      attr_accessor(*ATTRIBUTES)

      def new_record?
        id.nil?
      end

      def self.from_serialized_hash(link, index)
        self.new(
          id: index,
          title: link['label'],
          url: link['href']['value'],
          sort_priority: index)
      end

      def serializable_hash(options = nil)
        { label: title, href: {value: url} }
      end
    end

    ATTRIBUTES = [
      :id,
      :kind,
      :theme,
      :social_media_icon_color,
      :social_media_icon_color_hover,
      :links,
      :social,
      :copyright,
      :logo
    ].freeze

    DEFAULTS = {
      id: "footer",
      kind: "footer",
      theme: "logo",
      social_media_icon_color: {type: "marketplace_data", id: "primary_color"},
      social_media_icon_color_hover: {type: "marketplace_data", id: "primary_color_darken"},
      links: [ ],
      social: [
        {service: "facebook", url: ""},
        {service: "twitter", url: ""},
        {service: "instagram", url: ""},
        {service: "youtube", url: ""},
        {service: "googleplus", url: ""},
        {service: "linkedin", url: ""},
        {service: "pinterest", url: ""},
        {service: "soundcloud", url: ""}
      ],
      copyright: "",
      logo: { type: "marketplace_data", id: "logo" }
    }.freeze

    PERMITTED_PARAMS = [
      :id,
      :kind,
      :theme,
      :previous_id,
      :copyright,
      :social_attributes => LandingPageVersion::Section::Footer::SocialLink::ATTRIBUTES,
      :links_attributes => LandingPageVersion::Section::Footer::MenuLink::ATTRIBUTES,
    ].freeze

    attr_accessor(*(ATTRIBUTES + HELPER_ATTRIBUTES))

    def initialize(attributes={})
      super(attributes)
      @kind = LandingPageVersion::Section::FOOTER
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

    # serialize links and social as associations, not regular attributes
    def serializable_hash(options = nil)
      super({except: [:social, :links], include: [:social, :links]})
    end

    # called on initialization from model
    def social=(list)
      @social = list.map.with_index do |link, index|
        if link.is_a?(Hash)
          LandingPageVersion::Section::Footer::SocialLink.from_serialized_hash(link, index)
        else
          link
        end
      end
      add_missing_social
    end

    # called from controller
    def social_attributes=(params)
      @social = priority_sort(params).map do |attrs|
        LandingPageVersion::Section::Footer::SocialLink.new(attrs)
      end
      add_missing_social
    end

    # called on initialization from model
    def links=(list)
      @links = list.map.with_index do |link, index|
        if link.is_a?(Hash)
          LandingPageVersion::Section::Footer::MenuLink.from_serialized_hash(link, index)
        else
          link
        end
      end
    end

    # called from controller
    def links_attributes=(params)
      @links = priority_sort(params).reject{|r| r['_destroy'] == '1'}.map do |attrs|
        LandingPageVersion::Section::Footer::MenuLink.new(attrs)
      end
    end

    def new_footer_menu_link
      LandingPageVersion::Section::Footer::MenuLink.new
    end

    def priority_sort(params)
      params.values.sort_by{|p| p['sort_priority'].to_i}
    end

    # existing page versions may have only few social links, but we should show all to enable/disable
    def add_missing_social
      index = @social.size
      existing = @social.map(&:provider)

      DEFAULTS[:social].each do |link|
        new_link = link.stringify_keys.merge('enabled' => false)
        unless existing.include?(new_link['service'])
          @social << LandingPageVersion::Section::Footer::SocialLink.from_serialized_hash(new_link, index)
          index += 1
        end
      end
    end

    def i18n_key
      'footer'
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
